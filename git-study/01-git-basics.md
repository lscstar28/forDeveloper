# Git 기초

## 1. Git이란?

Git은 파일 변경 이력을 관리하는 **분산 버전 관리 시스템(DVCS)**이다.
중앙 서버 없이도 로컬에 전체 이력을 갖고 있고, 여러 명이 동시에 같은 프로젝트를 수정해도 이력을 병합할 수 있다.

핵심 개념:

| 용어 | 설명 |
|---|---|
| Repository (저장소) | 프로젝트의 변경 이력이 저장되는 공간 (`.git` 폴더) |
| Commit | 특정 시점의 변경 스냅샷 |
| Branch | 독립적으로 작업할 수 있는 작업 흐름의 갈래 |
| Remote | 원격 저장소 (GitHub, GitLab 등) |
| Working Directory / Staging Area / Repository | 파일이 거치는 3단계 영역 |

---

## 2. 저장소 시작하기

```bash
git init                       # 현재 폴더를 새 Git 저장소로 초기화
git clone <URL>                # 원격 저장소를 로컬로 복제
git clone <URL> 폴더명           # 지정한 이름의 폴더로 복제
```

---

## 3. 기본 작업 흐름 (Working Directory → Staging → Commit)

```bash
git status                     # 변경된 파일 상태 확인 (가장 자주 쓰는 명령어)
git diff                       # 아직 add하지 않은 변경 내용 확인
git diff --staged              # add된(스테이징된) 변경 내용 확인

git add 파일명                  # 특정 파일을 스테이징
git add .                      # 현재 폴더 전체를 스테이징
git add -p                     # 변경 내용을 부분(hunk) 단위로 선택하며 스테이징

git commit -m "커밋 메시지"       # 스테이징된 내용을 커밋
git commit -am "메시지"          # 이미 추적 중인 파일은 add+commit 한번에 (새 파일은 제외)
```

> 커밋 메시지는 "무엇을 왜 바꿨는지"가 드러나게 짧고 명확하게 쓴다. (예: `fix: 로그인 시 토큰 만료 처리 오류 수정`)

---

## 4. 히스토리 확인

```bash
git log                        # 커밋 이력 확인
git log --oneline              # 한 줄씩 간략히
git log --oneline --graph --all # 브랜치 구조까지 그래프로 보기
git show <커밋해시>              # 특정 커밋의 변경 내용 확인
git blame 파일명                 # 각 줄이 어떤 커밋에서 마지막으로 바뀌었는지 확인
```

---

## 5. 브랜치

```bash
git branch                     # 브랜치 목록 확인
git branch 브랜치명              # 새 브랜치 생성
git switch 브랜치명              # 브랜치 전환 (최신 방식)
git checkout 브랜치명            # 브랜치 전환 (기존 방식)
git switch -c 브랜치명           # 생성 + 전환 동시에
git branch -d 브랜치명           # 브랜치 삭제 (병합된 것만)
git branch -D 브랜치명           # 브랜치 강제 삭제

git merge 브랜치명               # 현재 브랜치에 다른 브랜치 병합
```

> `main`(또는 `master`)에서 직접 작업하지 말고, 기능 단위로 브랜치를 만들어 작업한 뒤 병합하는 것이 기본 워크플로다.

### `merge`의 동작 단위

`merge`는 브랜치를 통째로 합친다기보다, **현재 브랜치에 없는 커밋들을 가져와 반영**하는 것에 가깝다. 상황에 따라 두 방식 중 하나로 동작한다.

- **Fast-forward merge**: 현재 브랜치가 병합 대상 브랜치의 조상(ancestor)일 때. 새로 합칠 게 없으니 새 커밋을 만들지 않고 **브랜치 포인터만 앞으로 이동**시킨다. (히스토리가 계속 일직선)

  ```bash
  git merge --no-ff 브랜치명      # fast-forward가 가능해도 강제로 merge 커밋을 남김 (병합 이력 추적용)
  git merge --ff-only 브랜치명    # fast-forward가 불가능하면 merge 자체를 거부 (merge 커밋 생성 방지)
  ```

- **3-way merge**: 두 브랜치가 공통 조상 이후로 각자 다른 커밋을 쌓아 분기됐을 때. **공통 조상(base) + 브랜치 A 끝 + 브랜치 B 끝**, 이 세 지점을 비교해 변경 내용을 합치고, **부모가 2개인 merge 커밋**을 새로 만든다. 같은 부분을 양쪽에서 다르게 고쳤으면 여기서 충돌(conflict)이 발생한다. (→ 6번 충돌 해결 참고)

즉 "브랜치를 merge한다"는 말은 실제로는 "그 브랜치가 가리키는 커밋까지의 변경 내역(diff)을 현재 브랜치에 적용한다"는 뜻이다. 브랜치는 특정 커밋을 가리키는 이름표일 뿐이고, 실제 병합 대상은 항상 커밋이다.

### `switch` vs `checkout`

`checkout`은 원래 **"브랜치 전환"과 "파일 복원"을 한 명령어가 동시에 담당**하던 기존 방식이라, 용도가 겹쳐서 실수하기 쉬웠다. Git 2.23(2019)부터 이 두 역할을 나눈 `switch`(브랜치 전용)와 `restore`(파일 전용)가 추가됐다.

| | `checkout` | `switch` / `restore` |
|---|---|---|
| 브랜치 전환 | `git checkout 브랜치명` | `git switch 브랜치명` |
| 브랜치 생성+전환 | `git checkout -b 브랜치명` | `git switch -c 브랜치명` |
| 파일을 마지막 커밋 상태로 되돌리기 | `git checkout -- 파일명` | `git restore 파일명` |
| 특정 커밋 상태로 이동 (detached HEAD) | `git checkout <커밋해시>` | `git switch --detach <커밋해시>` |
| 특정 커밋의 파일만 가져오기 | `git checkout <커밋해시> -- 파일명` | `git restore --source <커밋해시> 파일명` |

- `git checkout 파일명`처럼 인자가 브랜치명인지 파일명인지에 따라 동작이 완전히 달라지는 게 `checkout`의 대표적인 함정이다. (예: 브랜치명과 똑같은 이름의 파일이 있으면 예상과 다르게 동작할 수 있음)
- `switch`/`restore`는 역할이 명확히 분리돼 있어 실수 가능성이 적다. **새로 배운다면 `switch`/`restore`를 기본으로 쓰고, `checkout`은 다른 사람 코드나 예전 문서에서 볼 때 이해할 수 있을 정도로만 알아두면 된다.**
- 구버전 Git(2.23 미만)에는 `switch`/`restore`가 없어 `checkout`만 써야 하는 경우도 있다.

### `branch -d` vs `branch -D`

```bash
git branch -d 브랜치명   # = --delete, "안전 삭제"
git branch -D 브랜치명   # = --delete --force, "강제 삭제"
```

- `-d`(소문자)는 **삭제하려는 브랜치의 커밋이 현재 브랜치(또는 upstream)에 전부 병합되어 있는지** 확인한 뒤에만 삭제를 허용한다. 병합되지 않은 커밋이 남아있으면 다음과 같이 에러를 내고 삭제를 거부한다.

  ```
  error: The branch 'feature/x' is not fully merged.
  If you are sure you want to delete it, run 'git branch -D feature/x'.
  ```

  즉 "병합된 것만 삭제"라는 말은, 병합 안 된 브랜치는 **아예 삭제가 안 되고 막힌다**는 뜻이다. 이 상태에서 정말 지우고 싶다면 안내대로 `-D`를 쓰거나, 먼저 병합/PR을 완료한 뒤 `-d`로 지운다.

- `-D`(대문자)는 병합 여부를 검사하지 않고 무조건 삭제한다. 그 브랜치에만 있던 커밋들은 어떤 브랜치의 이력에도 남아있지 않게 되므로, **참조가 완전히 끊겨 나중에 찾기 어려워진다.**
  - 단, Git이 커밋 자체를 즉시 지우는 건 아니라서 `git reflog`로 브랜치가 가리키던 커밋 해시를 찾아 `git branch 복구명 <커밋해시>`로 복구할 여지는 있다 (단, `reflog`는 기본적으로 로컬에서 일정 기간 후 만료됨).
- 판단 기준: "이 브랜치의 작업이 다른 곳에 이미 반영됐다"는 확신이 없다면 `-d`를 쓰고 에러가 나면 원인을 먼저 확인한다. "이 브랜치 자체를 통째로 버리는 게 맞다"는 확신이 있을 때만 `-D`를 쓴다.
- 원격 브랜치 삭제(`git push origin --delete 브랜치명`)는 이 병합 여부 검사를 하지 않으므로 더 주의가 필요하다.

---

## 6. 충돌(Conflict) 해결

병합 시 같은 부분을 서로 다르게 수정했다면 충돌이 발생한다.

```
<<<<<<< HEAD
현재 브랜치의 내용
=======
병합하려는 브랜치의 내용
>>>>>>> 브랜치명
```

해결 순서:

1. 충돌 표시(`<<<<<<<`, `=======`, `>>>>>>>`)가 있는 파일을 열어 원하는 내용으로 직접 수정
2. `git add 파일명`으로 해결됨을 표시
3. `git commit`으로 병합 커밋 완료 (메시지는 보통 자동 생성됨)

---

## 7. 원격 저장소

```bash
git remote -v                  # 연결된 원격 저장소 확인
git remote add origin <URL>     # 원격 저장소 연결

git fetch                      # 원격의 변경 내용을 가져오되 병합은 안 함
git pull                       # fetch + merge를 한번에 (기본 동작)
git pull --rebase              # merge 대신 rebase로 pull

git push                       # 현재 브랜치를 원격에 반영
git push -u origin 브랜치명      # 최초 push 시 추적 브랜치 설정
git push origin --delete 브랜치명 # 원격 브랜치 삭제
```

---

## 8. 되돌리기 (실수했을 때)

```bash
git restore 파일명               # 워킹 디렉토리의 변경사항 취소 (add 전 상태로)
git restore --staged 파일명      # add한 것을 취소 (스테이징만 해제, 내용은 유지)

git commit --amend             # 마지막 커밋 메시지/내용 수정
git reset --soft HEAD~1         # 마지막 커밋 취소, 변경 내용은 스테이징 상태로 유지
git reset --mixed HEAD~1        # 마지막 커밋 취소, 변경 내용은 워킹 디렉토리로 유지 (기본값)
git reset --hard HEAD~1         # 마지막 커밋과 변경 내용 모두 삭제 (주의! 복구 어려움)

git revert <커밋해시>            # 특정 커밋을 "취소하는 새 커밋"을 추가 (이력이 남아 협업 시 안전)
```

> ⚠️ `reset --hard`는 로컬 변경 내용을 완전히 버린다. 이미 push된 커밋에는 `revert`를 쓰는 것이 안전하다.

---

## 9. .gitignore

버전 관리에서 제외할 파일/폴더를 지정한다.

```
node_modules/
.env
dist/
*.log
.DS_Store
```

- 이미 커밋된 파일은 `.gitignore`에 추가해도 계속 추적된다 → `git rm --cached 파일명`으로 추적 해제 필요

---

## 10. 협업 워크플로 (PR 기반)

1. `main`에서 최신 상태로 새 브랜치 생성 (`feature/기능명`)
2. 작업 후 커밋, 원격에 push
3. GitHub 등에서 Pull Request(PR) 생성 → 코드 리뷰
4. 리뷰 반영 후 `main`에 병합 (merge / squash / rebase 중 팀 컨벤션에 따름)
5. 병합 후 로컬/원격 작업 브랜치 정리

```bash
git fetch origin
git switch -c feature/login origin/main   # 최신 main 기준으로 새 브랜치 시작
```

---

## 11. 자주 쓰는 조합 예시

```bash
# 현재까지 변경사항 확인 후 커밋
git status && git diff

# 특정 파일만 스테이징해서 커밋
git add src/app.ts && git commit -m "fix: app.ts 오류 수정"

# 원격 최신 내용 받고 내 작업을 그 위에 올리기
git pull --rebase origin main

# 커밋 안 된 변경사항 임시 저장 후 나중에 복원
git stash
git stash pop
```

---

## 다음에 공부할 것

기초는 여기까지. `rebase`, `cherry-pick`, `stash` 상세, `tag`, Git hooks, 커밋 컨벤션, 협업 워크플로(브랜치 전략, Fork&PR, PR 병합 방식, 코드 리뷰 관례)는 → [02-git-advanced.md](./02-git-advanced.md) 참고.

- [ ] GitHub Actions와 연계한 CI 기초 (심화 이후 별도 학습)
