"""미니 GPT 모델 정의 (문자 단위 언어모델).

Andrej Karpathy의 "Let's build GPT" 강의 구조를 따르되, 교육 목적으로
각 구성요소의 역할을 한글 주석으로 설명한다.

구조: 임베딩 -> [셀프어텐션 + 피드포워드] 블록 N개 -> 출력층
"""
import torch
import torch.nn as nn
from torch.nn import functional as F


class Head(nn.Module):
    """셀프 어텐션 헤드 1개.

    각 토큰이 "이전 토큰들 중 어디를 얼마나 참고할지" 가중치를 계산한다.
    Query(질문) · Key(단서) · Value(실제 정보) 세 가지 벡터로 나눠 계산하는 것이 핵심.
    """

    def __init__(self, n_embd, head_size, block_size, dropout):
        super().__init__()
        self.key = nn.Linear(n_embd, head_size, bias=False)
        self.query = nn.Linear(n_embd, head_size, bias=False)
        self.value = nn.Linear(n_embd, head_size, bias=False)
        # 미래 토큰을 못 보게 가리는 삼각 마스크 (언어모델은 "다음 단어 예측"이므로 미래를 참고하면 반칙)
        self.register_buffer("tril", torch.tril(torch.ones(block_size, block_size)))
        self.dropout = nn.Dropout(dropout)

    def forward(self, x):
        B, T, C = x.shape
        k = self.key(x)    # (B, T, head_size)
        q = self.query(x)  # (B, T, head_size)

        # 토큰 간 연관도(Attention Score) 계산: Query와 Key의 내적
        wei = q @ k.transpose(-2, -1) * C ** -0.5  # (B, T, T)
        wei = wei.masked_fill(self.tril[:T, :T] == 0, float("-inf"))  # 미래 마스킹
        wei = F.softmax(wei, dim=-1)  # 확률 분포로 정규화 (합=1)
        wei = self.dropout(wei)

        v = self.value(x)
        out = wei @ v  # 연관도 가중치로 Value를 가중합 -> 문맥이 반영된 표현
        return out


class MultiHeadAttention(nn.Module):
    """여러 개의 어텐션 헤드를 병렬로 두고 결과를 합친다.

    헤드마다 서로 다른 종류의 관계(문법 구조, 의미 관계 등)에 집중하도록 학습된다.
    """

    def __init__(self, n_embd, n_head, block_size, dropout):
        super().__init__()
        head_size = n_embd // n_head
        self.heads = nn.ModuleList(
            [Head(n_embd, head_size, block_size, dropout) for _ in range(n_head)]
        )
        self.proj = nn.Linear(n_embd, n_embd)
        self.dropout = nn.Dropout(dropout)

    def forward(self, x):
        out = torch.cat([h(x) for h in self.heads], dim=-1)
        return self.dropout(self.proj(out))


class FeedForward(nn.Module):
    """토큰별로 독립적으로 적용되는 완전연결층.

    어텐션이 "토큰들 사이의 관계"를 파악한다면, 이 층은 그 정보를 바탕으로
    각 토큰이 개별적으로 "생각을 정리"하는 역할을 한다.
    """

    def __init__(self, n_embd, dropout):
        super().__init__()
        self.net = nn.Sequential(
            nn.Linear(n_embd, 4 * n_embd),
            nn.ReLU(),
            nn.Linear(4 * n_embd, n_embd),
            nn.Dropout(dropout),
        )

    def forward(self, x):
        return self.net(x)


class Block(nn.Module):
    """트랜스포머 블록 1개 = 셀프 어텐션 + 피드포워드 (+ 잔차 연결, 정규화)."""

    def __init__(self, n_embd, n_head, block_size, dropout):
        super().__init__()
        self.sa = MultiHeadAttention(n_embd, n_head, block_size, dropout)
        self.ffwd = FeedForward(n_embd, dropout)
        self.ln1 = nn.LayerNorm(n_embd)
        self.ln2 = nn.LayerNorm(n_embd)

    def forward(self, x):
        # 잔차 연결(x + ...): 층을 깊게 쌓아도 학습이 안정적으로 되도록 하는 장치
        x = x + self.sa(self.ln1(x))
        x = x + self.ffwd(self.ln2(x))
        return x


class MiniGPT(nn.Module):
    """문자 단위 미니 GPT 언어모델."""

    def __init__(self, vocab_size, n_embd, n_head, n_layer, block_size, dropout):
        super().__init__()
        self.block_size = block_size
        # 토큰 임베딩: 각 문자를 n_embd 차원의 벡터로 변환
        self.token_embedding_table = nn.Embedding(vocab_size, n_embd)
        # 위치 임베딩: "몇 번째 위치의 토큰인지" 정보를 추가 (어텐션 자체는 순서를 모름)
        self.position_embedding_table = nn.Embedding(block_size, n_embd)
        self.blocks = nn.Sequential(
            *[Block(n_embd, n_head, block_size, dropout) for _ in range(n_layer)]
        )
        self.ln_f = nn.LayerNorm(n_embd)
        self.lm_head = nn.Linear(n_embd, vocab_size)  # 최종적으로 "다음 문자 확률 분포" 출력

    def forward(self, idx, targets=None):
        B, T = idx.shape
        tok_emb = self.token_embedding_table(idx)  # (B, T, n_embd)
        pos_emb = self.position_embedding_table(torch.arange(T, device=idx.device))
        x = tok_emb + pos_emb
        x = self.blocks(x)
        x = self.ln_f(x)
        logits = self.lm_head(x)  # (B, T, vocab_size)

        if targets is None:
            loss = None
        else:
            B, T, C = logits.shape
            logits_flat = logits.view(B * T, C)
            targets_flat = targets.view(B * T)
            loss = F.cross_entropy(logits_flat, targets_flat)

        return logits, loss

    @torch.no_grad()
    def generate(self, idx, max_new_tokens):
        """주어진 문맥(idx) 뒤에 이어질 문자를 한 글자씩 예측해서 덧붙인다."""
        for _ in range(max_new_tokens):
            idx_cond = idx[:, -self.block_size:]  # block_size만큼만 최근 문맥 사용
            logits, _ = self(idx_cond)
            logits = logits[:, -1, :]  # 마지막 위치의 예측만 사용
            probs = F.softmax(logits, dim=-1)
            idx_next = torch.multinomial(probs, num_samples=1)  # 확률적으로 샘플링
            idx = torch.cat((idx, idx_next), dim=1)
        return idx
