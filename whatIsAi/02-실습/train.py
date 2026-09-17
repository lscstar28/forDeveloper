"""미니 GPT 학습 스크립트.

data/input.txt를 문자 단위로 읽어 학습하고, 중간중간 모델이 생성한
텍스트를 출력해서 "학습이 진행될수록 그럴듯한 텍스트가 나오는" 과정을 보여준다.
"""
import os
import torch

from model import MiniGPT

# ── 하이퍼파라미터 (CPU에서도 몇 분 내로 돌아가도록 작게 설정) ──
batch_size = 32        # 한 번에 학습할 데이터 묶음 크기
block_size = 64         # 모델이 한 번에 보는 문맥(문자) 길이
max_iters = 3000        # 총 학습 반복 횟수
eval_interval = 300     # 이 주기마다 손실(loss)과 샘플 텍스트 출력
eval_iters = 50
learning_rate = 3e-4
n_embd = 128             # 임베딩(토큰을 표현하는 벡터) 차원
n_head = 4               # 어텐션 헤드 개수
n_layer = 4               # 트랜스포머 블록(층) 개수
dropout = 0.1

device = "cuda" if torch.cuda.is_available() else "cpu"
torch.manual_seed(1337)

DATA_PATH = os.path.join(os.path.dirname(__file__), "data", "input.txt")
CKPT_PATH = os.path.join(os.path.dirname(__file__), "checkpoint.pt")


def main():
    with open(DATA_PATH, "r", encoding="utf-8") as f:
        text = f.read()

    # ── 어휘집(vocab) 구성: 등장하는 모든 문자를 정수 인덱스로 매핑 ──
    chars = sorted(list(set(text)))
    vocab_size = len(chars)
    stoi = {ch: i for i, ch in enumerate(chars)}
    itos = {i: ch for i, ch in enumerate(chars)}
    encode = lambda s: [stoi[c] for c in s]
    decode = lambda l: "".join(itos[i] for i in l)

    print(f"디바이스: {device}")
    print(f"텍스트 길이: {len(text):,}자, 어휘 크기: {vocab_size}자")

    data = torch.tensor(encode(text), dtype=torch.long)
    n = int(0.9 * len(data))
    train_data = data[:n]
    val_data = data[n:]

    def get_batch(split):
        d = train_data if split == "train" else val_data
        ix = torch.randint(len(d) - block_size, (batch_size,))
        x = torch.stack([d[i:i + block_size] for i in ix])
        y = torch.stack([d[i + 1:i + block_size + 1] for i in ix])  # 정답 = 한 칸 밀린 시퀀스 (다음 문자 예측)
        return x.to(device), y.to(device)

    @torch.no_grad()
    def estimate_loss(model):
        out = {}
        model.eval()
        for split in ["train", "val"]:
            losses = torch.zeros(eval_iters)
            for k in range(eval_iters):
                x, y = get_batch(split)
                _, loss = model(x, y)
                losses[k] = loss.item()
            out[split] = losses.mean().item()
        model.train()
        return out

    model = MiniGPT(vocab_size, n_embd, n_head, n_layer, block_size, dropout).to(device)
    n_params = sum(p.numel() for p in model.parameters())
    print(f"모델 파라미터 수: {n_params:,}개")

    optimizer = torch.optim.AdamW(model.parameters(), lr=learning_rate)

    for it in range(max_iters + 1):
        if it % eval_interval == 0:
            losses = estimate_loss(model)
            print(f"[{it:5d}/{max_iters}] train loss {losses['train']:.4f} | val loss {losses['val']:.4f}")
            context = torch.zeros((1, 1), dtype=torch.long, device=device)
            sample = decode(model.generate(context, max_new_tokens=150)[0].tolist())
            print("  샘플 생성:", sample.replace("\n", " / "))

        xb, yb = get_batch("train")
        logits, loss = model(xb, yb)
        optimizer.zero_grad(set_to_none=True)
        loss.backward()
        optimizer.step()

    torch.save(
        {
            "model_state": model.state_dict(),
            "vocab_size": vocab_size,
            "stoi": stoi,
            "itos": itos,
            "config": dict(
                n_embd=n_embd, n_head=n_head, n_layer=n_layer,
                block_size=block_size, dropout=dropout,
            ),
        },
        CKPT_PATH,
    )
    print(f"\n체크포인트 저장 완료: {CKPT_PATH}")


if __name__ == "__main__":
    main()
