"""학습된 체크포인트를 불러와 텍스트를 생성하는 스크립트."""
import os
import sys
import torch

from model import MiniGPT

CKPT_PATH = os.path.join(os.path.dirname(__file__), "checkpoint.pt")
device = "cuda" if torch.cuda.is_available() else "cpu"


def main():
    n_tokens = int(sys.argv[1]) if len(sys.argv) > 1 else 500
    prompt = sys.argv[2] if len(sys.argv) > 2 else ""

    ckpt = torch.load(CKPT_PATH, map_location=device)
    cfg = ckpt["config"]
    stoi, itos = ckpt["stoi"], ckpt["itos"]
    encode = lambda s: [stoi[c] for c in s]
    decode = lambda l: "".join(itos[i] for i in l)

    model = MiniGPT(ckpt["vocab_size"], **cfg).to(device)
    model.load_state_dict(ckpt["model_state"])
    model.eval()

    if prompt:
        context = torch.tensor([encode(prompt)], dtype=torch.long, device=device)
    else:
        context = torch.zeros((1, 1), dtype=torch.long, device=device)

    out = model.generate(context, max_new_tokens=n_tokens)[0].tolist()
    print(decode(out))


if __name__ == "__main__":
    main()
