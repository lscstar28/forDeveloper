# model.py 코드 리뷰 (줄 단위 상세 분석)

우리가 학습에 쓴 실제 설정값 기준으로 구체적인 텐서 크기를 따라가며 정리한다.

```
vocab_size = 65    # 셰익스피어 텍스트에 등장하는 문자 종류 수
n_embd     = 128    # 임베딩 차원
n_head     = 4      # 어텐션 헤드 개수
n_layer    = 4       # 트랜스포머 블록 개수
block_size = 64      # 한 번에 보는 문맥 길이 (문자 수)
batch_size = 32      # 학습 시 한 배치에 묶는 샘플 수
```

기호: **B**=batch_size(32), **T**=시퀀스 길이(최대 block_size=64), **C**=채널/차원

---

## 1. `Head` 클래스 — 어텐션 헤드 1개 (13~42줄)

### 1-1. 생성자 (20~27줄)

```python
self.key   = nn.Linear(n_embd, head_size, bias=False)   # 128 -> 32
self.query = nn.Linear(n_embd, head_size, bias=False)   # 128 -> 32
self.value = nn.Linear(n_embd, head_size, bias=False)   # 128 -> 32
```

- `head_size = n_embd // n_head = 128 // 4 = 32`
- 세 개의 **서로 다른** 선형변환(가중치 행렬)을 각각 준비한다. 입력은 같은 `x`지만, Key/Query/Value는 각각 다른 관점으로 `x`를 "재해석"한 벡터다.
- `bias=False`인 이유: 원 논문(Attention Is All You Need) 구현을 따른 관례. 편향 없이도 충분하고 파라미터가 줄어든다.

```python
self.register_buffer("tril", torch.tril(torch.ones(block_size, block_size)))
```

- `torch.tril(torch.ones(64, 64))` → 64×64 크기의 아래쪽 삼각행렬(대각선 포함 그 아래는 1, 위는 0).
- `register_buffer`로 등록하는 이유: 이 값은 **학습되는 파라미터가 아니라 고정된 상수**이기 때문. `nn.Parameter`로 두면 옵티마이저가 이 값도 학습하려고 시도하는 오류가 남. buffer로 등록하면 `model.to(device)` 할 때 같이 GPU/CPU로 이동은 되지만 gradient는 계산 안 됨.

### 1-2. `forward` — 실제 계산 흐름 (29~42줄)

```python
B, T, C = x.shape
```
- 입력 `x`의 shape은 `(32, 64, 128)` → (배치, 시퀀스 길이, 임베딩 차원)

```python
k = self.key(x)    # (B, T, head_size) = (32, 64, 32)
q = self.query(x)  # (32, 64, 32)
```
- 각 토큰(문자) 하나하나에 대해 독립적으로 Linear 변환을 적용. 즉 64개 위치 각각이 자기만의 32차원 key 벡터, query 벡터를 갖게 됨.
- **비유**: `query`는 "내가 지금 무엇을 찾고 있는가"를 표현한 벡터, `key`는 "나는 이런 정보를 갖고 있다"는 이름표 같은 것.

```python
wei = q @ k.transpose(-2, -1) * C ** -0.5   # (32, 64, 64)
```
- `k.transpose(-2, -1)`: `(32, 64, 32)` → `(32, 32, 64)`로 마지막 두 차원을 뒤집음 (행렬곱을 위해)
- `q @ k^T`: `(32, 64, 32) @ (32, 32, 64) = (32, 64, 64)` → 결과의 `wei[b, i, j]`는 **b번째 샘플에서 i번째 토큰의 query와 j번째 토큰의 key를 내적한 값** = "i가 j를 얼마나 참고하고 싶어하는가"의 원점수(raw score)
- `* C ** -0.5`: `C=128`이므로 `128**-0.5 ≈ 0.088`을 곱함. 이 스케일링이 없으면 차원이 커질수록 내적값이 커져서 softmax가 한쪽으로 쏠려버리는 문제(gradient vanishing)가 생김 → 논문에서 제안한 "Scaled" Dot-Product Attention의 "Scaled"가 이 부분.

```python
wei = wei.masked_fill(self.tril[:T, :T] == 0, float("-inf"))
```
- `tril[:64, :64]`에서 값이 0인 위치(=미래 토큰 위치, 대각선 위쪽)를 `wei`에서 `-inf`로 덮어씀.
- 왜 `-inf`인가? 바로 다음 줄에서 softmax를 취하는데, `exp(-inf) = 0`이 되어 해당 위치의 참고 비중이 정확히 0이 되기 때문. 이렇게 해서 **i번째 토큰은 0~i번째 토큰까지만 보고, i+1번째 이후(미래)는 절대 못 봄** — 언어모델이 "다음 글자 맞히기"를 학습할 때 반칙(정답 미리보기)하지 못하게 막는 핵심 장치.

```python
wei = F.softmax(wei, dim=-1)
```
- 마지막 차원(각 토큰 i가 볼 수 있는 j들)에 대해 softmax → 합이 1인 확률분포로 변환. 즉 `wei[b, i, :]`는 "i번째 토큰이 0~i번째 토큰 각각을 얼마나 비중 있게 참고할지"의 확률.

```python
wei = self.dropout(wei)
```
- 학습 중 무작위로 일부 연결을 꺼서(0으로 만들어) 과적합을 방지. 추론(generate) 시에는 `model.eval()` 상태라 자동으로 비활성화됨.

```python
v = self.value(x)   # (32, 64, 32)
out = wei @ v        # (32, 64, 64) @ (32, 64, 32) = (32, 64, 32)
```
- `value`는 "실제로 전달할 정보". Query/Key는 "얼마나 참고할지 비중을 정하는 용도"일 뿐이고, 실제로 섞이는 내용물은 `value`.
- `wei @ v`: 각 토큰 i의 출력 = 비중(`wei[b,i,:]`)으로 가중평균한 모든 참고 토큰들의 value 벡터. 결과적으로 "문맥이 반영된" 새 표현이 나옴.

**한 문장 요약**: Query·Key로 "누굴 얼마나 볼지" 정하고, 그 비중으로 Value를 섞어서 문맥 정보를 담은 새 벡터를 만드는 것이 셀프 어텐션의 전부다.

---

## 2. `MultiHeadAttention` — 헤드 여러 개 병렬 실행 (45~62줄)

```python
head_size = n_embd // n_head   # 128 // 4 = 32
self.heads = nn.ModuleList([Head(...) for _ in range(n_head)])  # Head 4개
```
- `Head`를 4개 독립적으로 생성. 각자 다른 초기 가중치로 시작하므로 학습되면서 서로 다른 종류의 관계에 특화됨 (예: 헤드1은 바로 앞 글자 참고, 헤드2는 문장 시작 부분 참고 등 — 실제로 어떤 패턴을 학습할지는 데이터가 결정).

```python
out = torch.cat([h(x) for h in self.heads], dim=-1)
```
- 각 헤드 출력이 `(32, 64, 32)` 4개 → 마지막 차원으로 이어붙이면 `(32, 64, 128)`. `32 * 4 = 128 = n_embd`로 다시 맞아떨어짐.

```python
return self.dropout(self.proj(out))
```
- `self.proj`: `(128 -> 128)` Linear. 4개 헤드의 결과를 다시 한 번 섞어주는 역할(헤드별 정보가 서로 소통하도록).

---

## 3. `FeedForward` (65~82줄)

```python
nn.Linear(n_embd, 4 * n_embd),  # 128 -> 512
nn.ReLU(),
nn.Linear(4 * n_embd, n_embd),  # 512 -> 128
```
- 차원을 4배로 늘렸다가 다시 줄이는 구조 (Transformer 논문의 관례적 배율). 어텐션에서 모은 "문맥 정보"를 비선형 변환으로 한 번 더 가공하는 역할.
- 토큰별로 **독립적으로** 적용된다는 점이 어텐션과의 차이 — 여기선 토큰 간 상호작용이 없음.

---

## 4. `Block` — 어텐션 + 피드포워드 + 잔차연결 (85~99줄)

```python
x = x + self.sa(self.ln1(x))
x = x + self.ffwd(self.ln2(x))
```

- **`x +` (잔차 연결, residual connection)**: 층의 출력을 입력에 더해서 내보냄. 층을 깊게(4개, 실제 GPT는 수십~수백 개) 쌓아도 gradient가 소실되지 않고 잘 전달되게 하는 핵심 장치. 이게 없으면 층이 깊어질수록 학습이 잘 안 됨.
- **`self.ln1(x)` (LayerNorm)**: 어텐션/피드포워드에 넣기 *전에* 값의 분포를 정규화(평균 0, 분산 1 근처로). 학습을 안정시킴. (이 순서를 Pre-LN이라 부르며, 최신 GPT 계열이 주로 쓰는 방식)

---

## 5. `MiniGPT` 전체 조립 (102~147줄)

### 5-1. 임베딩 (108~111줄)

```python
self.token_embedding_table = nn.Embedding(vocab_size, n_embd)     # (65, 128)
self.position_embedding_table = nn.Embedding(block_size, n_embd)  # (64, 128)
```
- `token_embedding_table`: 문자 인덱스(0~64) → 128차원 벡터로 변환하는 **학습 가능한** 조회표(lookup table).
- `position_embedding_table`: "이 토큰이 몇 번째 위치인가"(0~63) → 128차원 벡터. 어텐션 연산 자체는 순서 개념이 없으므로(순서를 바꿔도 수학적으로 동일한 집합 연산), 위치 정보를 별도로 더해줘야 "글자 순서"를 모델이 알 수 있음.

### 5-2. forward (118~135줄)

```python
tok_emb = self.token_embedding_table(idx)   # (32, 64, 128)
pos_emb = self.position_embedding_table(torch.arange(T, device=idx.device))  # (64, 128)
x = tok_emb + pos_emb   # 브로드캐스팅되어 (32, 64, 128)
```
- `pos_emb`는 배치 차원이 없는데 `tok_emb`(배치 있음)와 더해질 때 자동으로 각 배치에 복사되어 더해짐(broadcasting).

```python
x = self.blocks(x)   # Block 4개를 순서대로 통과, shape 유지 (32, 64, 128)
x = self.ln_f(x)      # 마지막 정규화
logits = self.lm_head(x)   # (32, 64, 128) -> (32, 64, 65)
```
- `lm_head`: 128차원 내부 표현을 다시 vocab_size(65)차원으로 펼침 = "각 문자가 다음에 올 확률"에 대응하는 원점수(logit).

```python
loss = F.cross_entropy(logits_flat, targets_flat)
```
- `logits`를 `(B*T, C) = (2048, 65)`로, `targets`를 `(2048,)`로 펼쳐서 cross entropy 계산. Cross entropy는 "모델이 예측한 확률분포가 정답 문자와 얼마나 다른가"를 수치화 — 이 값을 줄이는 방향으로 역전파(backpropagation)하는 것이 학습의 전부.

### 5-3. generate — 실제 텍스트 생성 (137~147줄)

```python
idx_cond = idx[:, -self.block_size:]
```
- 지금까지 생성된 전체 시퀀스가 block_size(64)보다 길어지면, 모델이 학습 때 본 적 없는 길이라 최근 64자만 잘라서 씀 (위치 임베딩 테이블 크기가 64까지밖에 없기 때문이기도 함).

```python
logits, _ = self(idx_cond)
logits = logits[:, -1, :]   # (B, vocab_size) — 시퀀스의 "마지막 위치" 예측만 필요
probs = F.softmax(logits, dim=-1)
idx_next = torch.multinomial(probs, num_samples=1)
```
- `torch.multinomial`: 확률이 가장 높은 문자를 무조건 고르는 게 아니라, **확률분포를 따라 무작위로 샘플링**. 이래서 같은 프롬프트를 줘도 실행할 때마다 다른 문장이 나옴 (확률이 높은 문자가 뽑힐 가능성이 높을 뿐).
- `torch.cat((idx, idx_next), dim=1)`: 새로 뽑은 문자를 시퀀스 끝에 이어붙이고, 이 전체를 다시 모델에 넣는 걸 `max_new_tokens`번 반복 → 한 글자씩 순차적으로 문장을 늘려가는 것이 바로 "생성(generation)".

---

## 학습 결과와 연결해서 보기

- 학습 초반(loss 4.33): Q/K/V, 임베딩 모두 무작위값이므로 `wei`(어텐션 가중치)도 사실상 무의미한 값 → 완전 랜덤 문자 출력
- 학습 후반(loss 1.69): `key`/`query`가 "직전 몇 글자가 어떤 패턴일 때 다음 글자가 무엇이 오는지"를 반영하도록 가중치가 조정됨 → `QUEEN OF AURET:` 같은 그럴듯한 구조 생성

## 실제 상용 LLM과의 차이 (규모 외의 관점)

이 코드가 GPT-3/4, Claude와 **구조적으로 동일한 요소**를 담고 있다:
- 토큰 임베딩 + 위치 정보
- Multi-Head Self-Attention
- Feed Forward
- 잔차 연결 + LayerNorm
- 다음 토큰 예측으로 학습

차이는 주로 **규모와 디테일**:
- 레이어/헤드/임베딩 차원 수 (우리: 4층·4헤드·128차원 → GPT-3: 96층·96헤드·12288차원)
- 위치 인코딩 방식 (우리: 학습형 절대 위치 → 최신 모델은 RoPE 등 상대 위치 인코딩)
- 토큰화 방식 (우리: 글자 단위 → 실제론 BPE 등 서브워드 토큰화)
- 사전학습 후 RLHF/instruction tuning 등 추가 단계

즉 "원리는 이 코드 그대로, 크기와 공학적 디테일만 확장된 것"이라고 이해하면 된다.
