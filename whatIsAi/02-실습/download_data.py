"""학습용 텍스트 데이터를 내려받는 스크립트.

nanoGPT 튜토리얼에서 표준으로 쓰이는 Tiny Shakespeare 데이터셋을 사용한다.
(셰익스피어 희곡 텍스트, 약 1MB. 문자 단위 학습 데모에 적합한 크기)
"""
import os
import urllib.request

URL = "https://raw.githubusercontent.com/karpathy/char-rnn/master/data/tinyshakespeare/input.txt"
DEST = os.path.join(os.path.dirname(__file__), "data", "input.txt")

if __name__ == "__main__":
    os.makedirs(os.path.dirname(DEST), exist_ok=True)
    print(f"다운로드 중: {URL}")
    urllib.request.urlretrieve(URL, DEST)
    size = os.path.getsize(DEST)
    print(f"완료: {DEST} ({size:,} bytes)")
