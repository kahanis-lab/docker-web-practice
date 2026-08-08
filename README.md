# Docker Web Practice

Windows 11과 Docker Desktop 환경에서 Git/GitHub 저장소를 처음부터 구성하고, Ubuntu 컨테이너를 이용한 Linux CLI 실습부터 Nginx 커스텀 이미지, 포트 매핑, Bind Mount, Docker Volume까지 직접 수행한 과정을 기록한 프로젝트입니다.

이 문서는 명령어만 나열하지 않고 다음 네 가지를 함께 설명합니다.

1. 명령을 실행한 목적
2. 명령어와 옵션의 의미
3. 실제 확인한 출력 결과
4. 그 결과가 무엇을 증명하는지

---

## 1. 프로젝트 목표

- Windows에서 재현 가능한 Docker 개발 환경 구성
- Git 로컬 저장소와 GitHub 원격 저장소 연결
- Linux CLI를 사용한 파일·디렉터리 관리
- Linux 파일 권한과 `rwx`, `644`, `755` 이해
- Docker 이미지와 컨테이너의 차이 이해
- Dockerfile을 이용한 커스텀 Nginx 이미지 제작
- 호스트 포트와 컨테이너 포트를 연결하여 웹 서비스 공개
- Bind Mount를 이용한 실시간 소스 반영 검증
- Docker Volume을 이용한 데이터 영속성 검증
- Git 브랜치, Pull Request, Merge를 이용한 협업 흐름 실습

---

## 2. 요구사항 수행 현황

| 요구사항 | 상태 | 검증 위치 |
|---|---:|---|
| Git 사용자 및 기본 브랜치 설정 | 완료 | [5. Git/GitHub 초기 설정](#5-gitgithub-초기-설정) |
| GitHub 저장소 생성 및 원격 연결 | 완료 | [6. 로컬 저장소 생성 및 GitHub 연결](#6-로컬-저장소-생성-및-github-연결) |
| 실행 환경 및 버전 확인 | 완료 | [4. 실행 환경](#4-실행-환경) |
| Docker Engine 동작 확인 | 완료 | [8. Docker 설치 및 Engine 검증](#8-docker-설치-및-engine-검증) |
| `hello-world` 실행 | 완료 | [9. hello-world 실행](#9-hello-world-실행) |
| Ubuntu 이미지 다운로드 | 완료 | [10. Ubuntu 이미지 다운로드](#10-ubuntu-이미지-다운로드) |
| Ubuntu 컨테이너 및 Linux CLI | 완료 | [11. Ubuntu 컨테이너와 Linux CLI](#11-ubuntu-컨테이너와-linux-cli) |
| 파일 권한 변경 | 완료 | [13. Linux 파일 권한](#13-linux-파일-권한) |
| `attach`와 `exec` 비교 | 완료 | [14. 컨테이너 연결 방식 비교](#14-컨테이너-연결-방식-비교) |
| Dockerfile 및 커스텀 이미지 | 완료 | [16. 커스텀 Nginx 이미지 제작](#16-커스텀-nginx-이미지-제작) |
| 포트 매핑 및 HTTP 검증 | 완료 | [17. 컨테이너 실행과 포트 매핑](#17-컨테이너-실행과-포트-매핑) |
| Bind Mount 실시간 반영 | 완료 | [19. Bind Mount](#19-bind-mount) |
| Docker Volume 영속성 | 완료 | [20. Docker Volume](#20-docker-volume) |
| 브랜치 생성 및 원격 Push | 완료 | [22. 브랜치와 Pull Request](#22-브랜치와-pull-request) |
| Pull Request 생성 및 Merge | 완료 | [22. 브랜치와 Pull Request](#22-브랜치와-pull-request) |

---

## 3. 저장소 구조

```text
docker-web-practice/
├── .dockerignore
├── Dockerfile
├── README.md
├── images/
│   └── 실습 검증 이미지
└── site/
    └── index.html
```

| 경로 | 역할 |
|---|---|
| `Dockerfile` | Nginx 기반 커스텀 이미지를 만드는 설명서 |
| `.dockerignore` | Docker 빌드 컨텍스트에서 제외할 파일 지정 |
| `site/index.html` | Nginx가 제공하는 정적 웹페이지 |
| `images/` | 명령어 입력과 결과를 함께 촬영한 검증 자료 |
| `README.md` | 전체 실습 과정, 결과 및 트러블슈팅 문서 |

---

## 4. 실행 환경

| 항목 | 확인 결과 |
|---|---|
| 운영체제 | Microsoft Windows 11 Home |
| OS 버전 | 10.0.26200, Build 26200, 64비트 |
| 터미널 | Windows PowerShell 5.1.26100.8875 |
| Docker CLI / Engine | 29.6.2 |
| Docker Desktop | 4.84.0 |
| Docker Compose | v5.3.1 |
| Git | 2.55.0.windows.2 |
| VS Code | 1.130.0, x64 |
| Docker Context | `desktop-linux` |
| Docker Server OS/Arch | `linux/amd64` |

### 4.1 운영체제 확인

```powershell
Get-CimInstance Win32_OperatingSystem |
    Format-List Caption, Version, BuildNumber, OSArchitecture
```

`Format-List`를 사용하면 터미널 폭이 좁아도 각 속성이 세로로 표시되어 값이 잘리지 않습니다.

![Windows 실행 환경](<images/확인된 실행환경.png>)

### 4.2 프로그램 버전 확인

```powershell
$PSVersionTable.PSVersion
docker --version
git --version
code --version
```

- `--version`은 설치된 프로그램의 버전을 확인하는 공통 옵션입니다.
- 버전 출력이 나온다는 것은 실행 파일이 설치되어 있고 `PATH`에서도 찾을 수 있다는 뜻입니다.

![도구 버전 확인](<images/git 설정확인 버전들 .png>)

---

## 5. Git/GitHub 초기 설정

### 5.1 Git 전역 사용자 설정

```powershell
git config --global user.name "kahanis-lab"
git config --global user.email "<MASKED_EMAIL>"
git config --global init.defaultBranch main
```

| 설정 | 의미 |
|---|---|
| `user.name` | 커밋 작성자 이름 |
| `user.email` | 커밋 작성자 이메일 |
| `init.defaultBranch` | 새 저장소의 첫 번째 브랜치 이름 |
| `--global` | 현재 컴퓨터의 사용자 계정 전체에 적용 |

`user.name`은 GitHub 로그인 아이디와 반드시 같아야 하는 값은 아닙니다. Git 커밋에 기록될 작성자 이름입니다. 이메일은 공개 저장소에서 노출될 수 있으므로 README와 스크린샷에서는 마스킹합니다.



### 5.2 Git 전체 설정 확인

```powershell
git --no-pager config --list
```

처음 실행한 `git config --list`에서는 출력이 길어 Git의 pager가 열렸습니다. 화면에 나타난 `:`은 Git 설정값이 아니라 긴 출력을 보여주는 pager의 입력 프롬프트입니다. `q`를 누르면 종료할 수 있고, `--no-pager`를 사용하면 pager 없이 터미널에 바로 출력됩니다.

같은 설정이 반복되어 보이는 경우에는 시스템, 전역, 로컬 설정 파일에 같은 키가 각각 존재할 수 있습니다. 정확한 출처는 다음 명령으로 확인할 수 있습니다.

```powershell
git --no-pager config --list --show-origin
```

![Git 설정과 pager](<images/01-git-config.png less.png>)

주요 설정의 의미는 다음과 같습니다.

| 설정 | 의미 |
|---|---|
| `diff.astextplain.textconv=astextplain` | 일부 문서 형식을 텍스트로 변환하여 변경점을 비교하도록 지원 |
| `filter.lfs.*` | 대용량 파일을 별도 저장하는 Git LFS 관련 필터 |
| `http.sslbackend=schannel` | HTTPS 인증에 Windows 인증서 저장소 사용 |
| `core.autocrlf=true` | 체크아웃 시 LF를 CRLF로, 커밋 시 CRLF를 LF로 변환 |
| `core.fscache=true` | Windows 파일 시스템 접근 성능을 높이기 위한 캐시 |
| `core.symlinks=false` | 기본적으로 Windows 심볼릭 링크 생성을 사용하지 않음 |
| `pull.rebase=false` | `git pull`에서 기본적으로 rebase 대신 merge 사용 |
| `credential.helper=manager` | Git Credential Manager를 이용해 인증 정보 관리 |
| `credential.https://dev.azure.com.usehttppath=true` | Azure DevOps 인증 경로 구분에 사용하는 기본 설정 |
| `init.defaultbranch=main` | 새 저장소의 기본 브랜치를 `main`으로 지정 |

#### `core.autocrlf=true`가 Docker 실습에서 중요한 이유

Windows는 주로 CRLF 줄바꿈을 사용하고 Linux는 LF 줄바꿈을 사용합니다. Linux 컨테이너에서 실행할 셸 스크립트가 CRLF로 저장되면 `\r` 문자가 포함되어 파일이 존재하는데도 실행되지 않는 것처럼 보일 수 있습니다. 따라서 Docker와 Linux용 스크립트는 LF 형식을 유지하는 것이 안전합니다.

---

## 6. 로컬 저장소 생성 및 GitHub 연결

### 6.1 GitHub 원격 저장소 생성

GitHub에서 `docker-web-practice`라는 Public 저장소를 만들었습니다. 로컬에서 Git의 전체 흐름을 실습하기 위해 생성 단계에서는 README, `.gitignore`, License를 추가하지 않고 빈 저장소로 만들었습니다.

![GitHub 저장소 생성 설정](<images/docker-web-practice저장소 생성.png>)

![빈 GitHub 저장소 생성 완료](<images/저장소생성 완료.png>)

### 6.2 프로젝트 디렉터리 생성과 이동

```powershell
mkdir docker-web-practice
cd docker-web-practice
Get-Location
Get-ChildItem -Force
```

| 명령 | 의미 |
|---|---|
| `mkdir` | 새 디렉터리 생성 |
| `cd` | 현재 작업 디렉터리 변경 |
| `Get-Location` | 현재 위치 확인. Linux의 `pwd`와 같은 역할 |
| `Get-ChildItem -Force` | 숨김 항목을 포함한 파일 목록 확인 |

![프로젝트 디렉터리 생성](<images/docker-webp-practice mkdir.png>)

![현재 경로 확인](<images/cd로이동,get-location위치확인.png>)

### 6.3 로컬 Git 저장소 초기화

```powershell
git init
```

`git init`은 현재 폴더에 `.git` 디렉터리를 생성합니다. `.git`에는 커밋, 브랜치, 설정과 같은 버전 관리 정보가 저장됩니다. 프로젝트 파일을 Git으로 바꾸는 것이 아니라 현재 폴더를 Git이 추적할 수 있는 저장소로 초기화하는 명령입니다.

```powershell
Get-ChildItem -Force
git status
```

초기 상태에서 `On branch main`, `No commits yet`가 표시되었습니다.

![Git 저장소 초기화](<images/git init 결과 .png>)

![숨김 .git 디렉터리 확인](<images/init후 force확인.png>)

![초기 Git 상태](<images/init force확인 후status확인.png>)

### 6.4 README 생성과 UTF-8 인코딩 문제

Windows PowerShell에서 빈 README 파일을 만들었습니다.

```powershell
New-Item README.md -ItemType File
```

`New-Item`은 PowerShell의 파일·디렉터리 생성 명령입니다. Linux의 `touch`와 비슷하게 빈 파일을 만들 수 있지만, `-ItemType File`로 생성 대상이 파일임을 명확히 지정합니다.

VS Code에서 한글을 작성한 뒤 다음 명령으로 확인했을 때 한글이 깨져 보였습니다.

```powershell
Get-Content README.md
```

파일 자체가 손상된 것이 아니라 Windows PowerShell 5.1이 UTF-8 파일을 다른 문자 인코딩으로 해석한 문제였습니다.

```powershell
Get-Content README.md -Encoding UTF8
```

`-Encoding UTF8`을 명시하자 한글이 정상적으로 출력되었습니다.

![PowerShell UTF-8 문제 해결](<images/글자꺠짐오류고침.png>)

### 6.5 Working Tree, Staging Area, Commit

```powershell
git status
git add README.md
git status
```

- 처음에는 `README.md`가 빨간색 `Untracked files`로 표시되었습니다.
- `git add` 후에는 녹색 `Changes to be committed`로 변경되었습니다.
- `git add`는 GitHub에 업로드하는 명령이 아니라 다음 커밋에 포함할 변경을 Staging Area에 등록하는 명령입니다.

![README 스테이징](<images/git add과정.png>)

```powershell
git commit -m "Add initial README"
git status
git log --oneline
```

`git commit`은 Staging Area의 변경을 하나의 버전으로 로컬 저장소에 기록합니다. `-m` 뒤의 문자열은 변경 목적을 설명하는 커밋 메시지입니다.

![최초 커밋](<images/git 첫커밋.png>)

### 6.6 원격 저장소 연결

```powershell
git remote add origin https://github.com/kahanis-lab/docker-web-practice.git
git remote -v
```

| 구성 | 의미 |
|---|---|
| `remote add` | 새로운 원격 저장소 등록 |
| `origin` | 원격 저장소에 붙인 기본 별칭 |
| `-v` | fetch와 push 주소를 자세히 출력 |

`origin`은 GitHub 자체를 뜻하는 예약어가 아니라 해당 URL에 붙인 별칭입니다.

![GitHub 원격 저장소 연결](<images/git 연동!.png>)

### 6.7 최초 Push

```powershell
git push -u origin main
```

- `push`: 로컬 커밋을 원격 저장소로 전송
- `origin`: 전송할 원격 저장소
- `main`: 전송할 브랜치
- `-u`: 로컬 `main`과 원격 `origin/main`의 upstream 연결 설정

upstream을 한 번 설정하면 이후에는 `git push`, `git pull`처럼 저장소와 브랜치 이름을 생략할 수 있습니다.

![GitHub 최초 Push](<images/git push과정 .png>)

![GitHub에서 README 확인](<images/commit성공 hub창.png>)

---

## 7. PowerShell과 Linux CLI 구분

호스트 터미널은 Windows PowerShell이고 Linux 명령은 Ubuntu 컨테이너 안에서 실행했습니다.

| 작업 | Windows PowerShell | Linux/Ubuntu |
|---|---|---|
| 현재 위치 | `Get-Location` | `pwd` |
| 목록 확인 | `Get-ChildItem` | `ls -la` |
| 파일 생성 | `New-Item file -ItemType File` | `touch file` |
| 디렉터리 생성 | `mkdir` 또는 `New-Item -ItemType Directory` | `mkdir` |
| 파일 내용 | `Get-Content` | `cat` |
| 권한 변경 | NTFS ACL 사용 | `chmod` |

Windows PowerShell에는 Linux의 `chmod`가 없고, PowerShell의 `ls`는 실제 Linux `ls`가 아니라 `Get-ChildItem`의 별칭입니다. 따라서 `chmod`, `ls -ld`, `rwx` 권한 실습은 Ubuntu 컨테이너 안에서 수행했습니다.

---

## 8. Docker 설치 및 Engine 검증

### 8.1 CLI 버전 확인과 Engine 확인의 차이

```powershell
docker --version
```

이 명령은 Docker CLI가 설치되었는지 확인합니다. 하지만 CLI 출력만으로 Docker Engine이 실행 중이라는 사실까지 증명하지는 못합니다.

```powershell
docker version
```

`docker version`에서 `Client`와 `Server`가 모두 출력되면 다음을 확인할 수 있습니다.

- Docker CLI가 정상 설치됨
- CLI가 Docker Engine API와 통신함
- Windows 클라이언트가 Linux Docker Engine을 사용함
- 현재 Context가 `desktop-linux`임

실제 확인 결과 Client는 `windows/amd64`, Server는 `linux/amd64`였습니다. Docker Desktop이 WSL2 기반 Linux 가상 환경에서 Linux 컨테이너를 실행하고 있다는 뜻입니다.

![Docker Client와 Server 확인](<images/docker version 확인.png>)

Docker Desktop 화면의 왼쪽 아래에서도 `Engine running` 상태를 확인했습니다.

![Docker Desktop Engine 실행](<images/docker info server.png>)

### 8.2 Docker 정보 확인

```powershell
docker info
```

`docker info`는 컨테이너 수, 이미지 수, Storage Driver, Logging Driver, Runtime 등 Engine 전체 정보를 보여줍니다. 전체 출력에는 Windows 사용자 경로와 같은 개인정보가 포함될 수 있으므로 공개 README에는 필요한 부분만 사용하고 개인정보는 마스킹합니다.

---

## 9. hello-world 실행

```powershell
docker run hello-world
```

처음 이미지가 없다면 Docker는 다음 순서로 동작합니다.

1. Docker CLI가 Docker Engine에 실행 요청
2. 로컬에 이미지가 없으면 Docker Hub에서 `hello-world` 이미지 다운로드
3. 이미지로 새 컨테이너 생성
4. 컨테이너의 `/hello` 프로그램 실행
5. 출력 결과를 터미널로 전달
6. 프로그램 종료와 함께 컨테이너 종료

`Hello from Docker!`가 출력되어 이미지 다운로드, 컨테이너 생성 및 실행이 모두 정상임을 확인했습니다.

![hello-world 실행](<images/docker run hello world.png>)

```powershell
docker ps -a --latest
```

- `ps`: 컨테이너 목록 확인
- `-a`: 종료된 컨테이너 포함
- `--latest`: 가장 최근 컨테이너 한 개 표시

결과의 `Exited (0)`은 프로그램이 오류 없이 정상 종료되었다는 뜻입니다. 직접 이름을 지정하지 않았기 때문에 Docker가 임의의 컨테이너 이름을 생성했습니다.

![hello-world 종료 상태](<images/docker ps -a --latest.png>)

---

## 10. Ubuntu 이미지 다운로드

```powershell
docker pull ubuntu:latest
docker images ubuntu
```

- `pull`: Registry에서 이미지만 미리 다운로드
- `ubuntu`: 이미지 저장소 이름
- `latest`: 이미지 태그. ‘가장 최신 LTS를 영구 보장’한다는 뜻이 아니라 현재 `latest`로 지정된 버전
- `docker images`: 로컬 이미지 목록 확인

실습 당시 `ubuntu:latest`는 Ubuntu 26.04 LTS였으며 이미지 ID와 로컬 저장 크기를 확인했습니다.

![Ubuntu 이미지 다운로드 및 확인](<images/pull이미지 가져오고 확인 .png>)

### 이미지와 컨테이너의 차이

| 구분 | 이미지 | 컨테이너 |
|---|---|---|
| 비유 | 실행 환경의 설계도 | 설계도로 실제 만든 실행 인스턴스 |
| 상태 | 읽기 전용 레이어 | 이미지 위에 쓰기 가능한 레이어 추가 |
| 명령 예시 | `docker pull`, `docker build` | `docker run`, `docker start` |
| 삭제 영향 | 새 컨테이너 생성에 필요 | 기본적으로 해당 컨테이너 내부 변경이 사라짐 |

---

## 11. Ubuntu 컨테이너와 Linux CLI

### 11.1 대화형 컨테이너 실행

```powershell
docker run -it --name ubuntu-cli-practice ubuntu:latest bash
```

| 옵션/인자 | 의미 |
|---|---|
| `run` | 이미지로 새 컨테이너 생성 후 실행 |
| `-i` | 표준 입력을 열린 상태로 유지 |
| `-t` | 터미널처럼 사용할 수 있는 가상 TTY 할당 |
| `--name` | 컨테이너 이름 지정 |
| `ubuntu:latest` | 사용할 이미지 |
| `bash` | 컨테이너 시작 시 실행할 명령 |

프롬프트가 PowerShell의 `PS C:\...>`에서 `root@컨테이너ID:/#`로 바뀌었습니다. 이후 명령은 Windows가 아니라 Ubuntu 컨테이너 안에서 실행됩니다.

```bash
whoami
pwd
cat /etc/os-release
echo "Hello from Ubuntu container"
```

- `whoami` 결과 `root`: 컨테이너 내부 현재 사용자가 root
- `pwd` 결과 `/`: Linux 최상위 디렉터리
- `/etc/os-release`: Ubuntu 배포판과 버전 정보

![Ubuntu 컨테이너 실행과 배포판 확인](<images/컨테이너 실행,pwd cat os-release.png>)

### 11.2 Linux 최상위 디렉터리 확인

```bash
ls -la /
```

- `ls`: 디렉터리 내용 출력
- `-l`: 권한, 소유자, 크기, 수정 시각을 포함한 상세 형식
- `-a`: `.`으로 시작하는 숨김 항목 포함
- `/`: 조회할 절대 경로

![Linux 최상위 디렉터리](<images/ls -la.png>)

### 11.3 실습 디렉터리 생성

```bash
mkdir -p /practice/linux-cli
cd /practice/linux-cli
pwd
```

- `mkdir -p`: 중간 디렉터리가 없어도 함께 생성하고, 이미 존재해도 오류 없이 진행
- `/practice/linux-cli`: `/`부터 시작하는 절대 경로
- `cd`: 현재 작업 디렉터리 변경

![Linux CLI 실습 경로](<images/실습폴더만들고확인container.png>)

---

## 12. Linux 파일 생성·복사·이동·삭제

### 12.1 생성, 출력, 복사, 이름 변경

```bash
touch original.txt
echo "Linux CLI practice" > original.txt
cat original.txt
cp original.txt copied.txt
mv copied.txt renamed.txt
mkdir backup
cp renamed.txt backup/
ls -la
ls -la backup
```

| 명령 | 역할 |
|---|---|
| `touch original.txt` | 빈 파일 생성. 파일이 있으면 수정 시각 갱신 |
| `echo ... > file` | 문자열을 파일에 기록. `>`는 기존 내용을 덮어씀 |
| `cat file` | 파일 내용 출력 |
| `cp source target` | 원본을 복사하여 새 파일 생성 |
| `mv old new` | 파일 이동 또는 이름 변경 |
| `mkdir backup` | 디렉터리 생성 |
| `cp file backup/` | 파일을 디렉터리 안으로 복사 |

![Linux 파일 생성·복사·이동](<images/touch , echo, cat,cp,mv,cp확인.png>)

### 12.2 파일과 빈 디렉터리 삭제

```bash
rm renamed.txt
rm backup/renamed.txt
rmdir backup
ls -la
```

- `rm`: 파일 삭제
- `rmdir`: 비어 있는 디렉터리만 삭제
- 디렉터리에 파일이 남아 있으면 `rmdir`은 실패하므로 내부 파일을 먼저 삭제했습니다.

![Linux 파일과 디렉터리 삭제](<images/rm rmdir .png>)

### 12.3 절대 경로와 상대 경로

| 구분 | 예시 | 기준 |
|---|---|---|
| 절대 경로 | `/practice/linux-cli/original.txt` | Linux 최상위 `/`부터 전체 위치 표시 |
| 상대 경로 | `original.txt`, `backup/renamed.txt` | 현재 작업 디렉터리를 기준으로 표시 |

`pwd`로 현재 위치를 확인하면 상대 경로가 실제로 어느 위치를 가리키는지 판단할 수 있습니다.

---

## 13. Linux 파일 권한

### 13.1 권한을 제한한 상태

```bash
mkdir test-dir
chmod 600 original.txt
chmod 700 test-dir
ls -ld original.txt test-dir
```

실행 결과:

```text
-rw------- original.txt
drwx------ test-dir
```

![권한 600과 700](<images/chmod 권한 수정.png>)

### 13.2 일반적인 파일·디렉터리 권한으로 변경

```bash
chmod 644 original.txt
chmod 755 test-dir
ls -ld original.txt test-dir
```

실행 결과:

```text
-rw-r--r-- original.txt
drwxr-xr-x test-dir
```

![권한 644와 755](<images/chmod 권한 수 정2.png>)

### 13.3 `rwx`와 숫자 권한 계산

| 권한 | 숫자 | 파일 | 디렉터리 |
|---|---:|---|---|
| `r` | 4 | 내용 읽기 | 목록 읽기 |
| `w` | 2 | 내용 수정 | 내부 항목 생성·삭제 |
| `x` | 1 | 파일 실행 | 디렉터리 내부로 진입·탐색 |

세 자리 숫자는 `소유자 / 그룹 / 기타 사용자` 순서입니다.

- `6 = 4 + 2`: 읽기 + 쓰기
- `7 = 4 + 2 + 1`: 읽기 + 쓰기 + 실행
- `5 = 4 + 1`: 읽기 + 실행
- `4`: 읽기

따라서 `644`는 소유자가 읽기·쓰기, 나머지는 읽기만 가능하고, `755`는 소유자가 모든 권한을 가지며 나머지는 디렉터리를 읽고 탐색할 수 있습니다.

---

## 14. 컨테이너 연결 방식 비교

### 14.1 `exit` 후 컨테이너 상태

최초 `docker run -it ... bash`로 실행된 Bash에서 `exit`하면 컨테이너의 주 프로세스인 Bash가 종료됩니다. 컨테이너는 주 프로세스가 끝나면 함께 종료됩니다.

```bash
exit
```

```powershell
docker ps --filter name=ubuntu-cli-practice
docker ps -a --filter name=ubuntu-cli-practice
```

- `docker ps`: 실행 중인 컨테이너만 표시
- `docker ps -a`: 종료된 컨테이너도 표시

![Ubuntu 컨테이너 종료 상태](<images/container종료후 확인 .png>)

### 14.2 `docker start`

```powershell
docker start ubuntu-cli-practice
docker ps --filter name=ubuntu-cli-practice
```

`docker start`는 기존 컨테이너를 다시 시작합니다. `docker run`처럼 새 컨테이너를 만들지 않으므로 이전 컨테이너의 파일 변경이 남아 있었습니다.

![기존 컨테이너 다시 시작](<images/docker start 확인.png>)

### 14.3 `docker exec`

```powershell
docker exec -it ubuntu-cli-practice bash
```

`exec`는 실행 중인 컨테이너 안에서 새로운 프로세스를 추가로 시작합니다. 새 Bash를 종료해도 원래 컨테이너의 주 프로세스는 계속 실행되므로 컨테이너는 `Up` 상태를 유지합니다.

```bash
cat /practice/linux-cli/original.txt
ls -ld /practice/linux-cli/original.txt /practice/linux-cli/test-dir
exit
```

파일 내용과 권한이 유지되는 것도 확인했습니다.

![docker exec 실습](<images/exec실습.png>)

### 14.4 `docker attach`

```powershell
docker attach ubuntu-cli-practice
```

`attach`는 컨테이너에서 이미 실행 중인 주 프로세스의 입출력에 직접 연결합니다. 이 상태에서 Bash에 `exit`를 입력하면 주 프로세스 자체가 끝나기 때문에 컨테이너도 종료되었습니다.

![docker attach 실습](<images/attach 실습.png>)

| 명령 | 새 프로세스 생성 | `exit`의 영향 | 대표 용도 |
|---|---:|---|---|
| `docker attach` | 아니요 | 주 프로세스를 종료할 수 있음 | 기존 주 프로세스 화면 연결 |
| `docker exec -it ... bash` | 예 | 추가 Bash만 종료, 컨테이너 유지 | 실행 중 컨테이너 점검·관리 |

일반적인 점검 작업에는 컨테이너를 실수로 종료할 가능성이 적은 `docker exec`가 더 적합합니다.

---

## 15. Docker 운영 명령

### 15.1 로그 확인

```powershell
docker logs --tail 20 ubuntu-cli-practice
```

- `logs`: 컨테이너의 표준 출력과 표준 오류 확인
- `--tail 20`: 마지막 20줄만 출력

### 15.2 리소스 확인

```powershell
docker stats --no-stream ubuntu-cli-practice
```

- `stats`: CPU, 메모리, 네트워크, 디스크 I/O, 프로세스 수 표시
- 기본값은 계속 갱신되며 `--no-stream`은 한 번만 출력하고 종료

실습 당시 CPU 사용률, 메모리 사용량, Network I/O, Block I/O, PIDS를 확인했습니다.

![컨테이너 로그와 리소스](<images/log 리소스 확인.png>)

### 15.3 컨테이너 중지

```powershell
docker stop ubuntu-cli-practice
docker ps --filter name=ubuntu-cli-practice
docker ps -a --filter name=ubuntu-cli-practice
```

실습에서는 종료 코드가 `Exited (137)`로 표시되었습니다. Unix 계열에서 강제 종료 신호 `SIGKILL`의 번호는 9이고, 신호로 종료된 프로세스는 관례적으로 `128 + 신호 번호`를 사용하므로 `128 + 9 = 137`이 됩니다. 즉, 정상 완료 코드 `0`이 아니라 강제 종료된 상태임을 알 수 있습니다.

![컨테이너 중지 결과](<images/container중지 .png>)

---

## 16. 커스텀 Nginx 이미지 제작

### 16.1 파일 구성

```powershell
New-Item site -ItemType Directory
New-Item site\index.html -ItemType File
New-Item Dockerfile -ItemType File
New-Item .dockerignore -ItemType File
```

![Nginx 프로젝트 파일 생성](<images/NGNIX1.png>)

### 16.2 Dockerfile

```dockerfile
FROM nginx:alpine

LABEL org.opencontainers.image.title="docker-web-practice"
LABEL org.opencontainers.image.description="Static Nginx web server for Docker practice"

COPY site/ /usr/share/nginx/html/

EXPOSE 80
```

| 명령 | 목적 |
|---|---|
| `FROM nginx:alpine` | 공식 Nginx 이미지 중 비교적 작은 Alpine Linux 기반 이미지를 베이스로 선택 |
| `LABEL ...title` | 이미지의 이름에 관한 메타데이터 추가 |
| `LABEL ...description` | 이미지 목적 설명 추가 |
| `COPY site/ ...` | 호스트의 정적 웹 파일을 Nginx 기본 웹 루트에 복사 |
| `EXPOSE 80` | 컨테이너가 80번 포트를 사용한다는 메타데이터 기록 |

`EXPOSE 80`만으로 호스트에서 접속할 수 있는 것은 아닙니다. 실제 호스트 포트 공개는 컨테이너 실행 시 `-p` 옵션으로 설정합니다.

### 16.3 `.dockerignore`

```text
.git
images
README.md
```

Docker Build에서 마지막의 `.`은 현재 폴더 전체를 Build Context로 전달한다는 뜻입니다. `.dockerignore`는 이미지 제작에 필요 없는 Git 이력, 스크린샷, 문서를 Context에서 제외하여 전송량, 캐시 무효화, 이미지에 불필요한 파일이 들어갈 위험을 줄입니다.

![Dockerfile과 .dockerignore](<images/Dockerfile,ignore.png>)

### 16.4 이미지 빌드

```powershell
docker build -t docker-web-practice:1.0 .
```

| 구성 | 의미 |
|---|---|
| `build` | Dockerfile로 이미지 생성 |
| `-t` | 이미지 이름과 태그 지정 |
| `docker-web-practice` | 이미지 저장소 이름 |
| `1.0` | 이미지 버전 태그 |
| `.` | 현재 디렉터리를 Build Context로 사용 |

Build 출력에서 `.dockerignore`가 적용된 작은 Build Context가 전달되고, `COPY site/ /usr/share/nginx/html/` 단계와 이미지 export가 완료된 것을 확인했습니다.

```powershell
docker images docker-web-practice
```

결과에서 `docker-web-practice:1.0` 이미지, 이미지 ID 및 로컬 저장 크기를 확인했습니다.

![커스텀 이미지 빌드](<images/build로 이미지만들기.png>)

### 16.5 이미지 설정 검증

PowerShell에서 Docker의 JSON 결과를 객체로 변환해 확인했습니다.

```powershell
$config = (docker image inspect docker-web-practice:1.0 | ConvertFrom-Json)[0].Config
$config.Labels | Format-List
$config.ExposedPorts | Format-List
$config.Entrypoint
$config.Cmd
```

확인 결과:

- 커스텀 title과 description Label 존재
- `80/tcp` 노출 정보 존재
- Nginx 베이스 이미지의 `/docker-entrypoint.sh` 상속
- `nginx -g 'daemon off;'` 명령 상속

Nginx를 `daemon off;`로 실행하는 이유는 웹 서버 프로세스를 포그라운드에 유지하여 Docker가 컨테이너의 생존 상태를 관리할 수 있게 하기 위해서입니다.

![커스텀 이미지 설정 확인](<images/만든이미지설정확인.png>)

---

## 17. 컨테이너 실행과 포트 매핑

### 17.1 8080 포트 사용 여부 확인

```powershell
docker ps --filter publish=8080 --format "table {{.Names}}\t{{.Ports}}"
```

기존 `bind-test` 컨테이너가 호스트 8080 포트를 사용하고 있었기 때문에 새 컨테이너에는 8081을 사용했습니다.

### 17.2 커스텀 Nginx 컨테이너 실행

```powershell
docker run -d --name nginx-web-practice -p 8081:80 docker-web-practice:1.0
```

| 옵션 | 의미 |
|---|---|
| `-d` | 터미널을 점유하지 않고 백그라운드 실행 |
| `--name nginx-web-practice` | 관리하기 쉬운 컨테이너 이름 지정 |
| `-p 8081:80` | 호스트 8081 포트를 컨테이너 80 포트에 연결 |
| `docker-web-practice:1.0` | 앞에서 빌드한 커스텀 이미지 사용 |

`8081:80`에서 왼쪽은 Windows 호스트 포트, 오른쪽은 컨테이너 내부 Nginx 포트입니다.

```powershell
docker ps --filter name=nginx-web-practice
```

`0.0.0.0:8081->80/tcp`가 표시되어 포트 매핑과 실행 상태를 확인했습니다.

![Nginx 컨테이너 포트 매핑](<images/port연결.png>)

### 17.3 HTTP 응답 확인

```powershell
curl.exe -I http://localhost:8081
```

PowerShell 5.1에서는 `curl`이 `Invoke-WebRequest`의 별칭일 수 있으므로 실제 curl 실행 파일을 명확히 사용하기 위해 `curl.exe`를 입력했습니다.

`-I`는 본문 전체를 받지 않고 응답 헤더만 요청합니다. `HTTP/1.1 200 OK`가 출력되어 Nginx가 요청을 정상 처리했음을 확인했습니다.

![HTTP 200 응답](<images/http응답확인 보기.png>)

브라우저에서도 `http://localhost:8081`에 접속하여 커스텀 페이지가 표시되는 것을 확인했습니다.

![커스텀 Nginx 웹페이지](<images/NGNIX3깔끔.png>)

---

## 18. Nginx 로그 검증

```powershell
docker logs --tail 20 nginx-web-practice
```

로그에서 다음 내용을 확인했습니다.

- Nginx 설정 초기화 완료
- Worker Process 시작
- `HEAD / HTTP/1.1` 요청에 `200` 응답
- 브라우저의 `GET / HTTP/1.1` 요청에 `200` 응답
- `/favicon.ico` 요청에 `404` 응답

웹페이지 자체의 `GET /`는 성공했습니다. `favicon.ico` 404는 브라우저가 주소창 아이콘을 자동 요청했지만 해당 파일을 만들지 않아 발생한 것으로, 메인 페이지 실패가 아닙니다.

![Nginx 실행 및 HTTP 로그](<images/NGXNIX2.png>)

---

## 19. Bind Mount

### 19.1 목적

이미지에 `COPY`된 파일은 이미지를 다시 빌드하지 않으면 바뀌지 않습니다. 개발 중에는 호스트의 소스 파일을 저장할 때마다 즉시 확인할 필요가 있으므로 호스트 폴더와 컨테이너 폴더를 Bind Mount로 직접 연결했습니다.

### 19.2 Bind Mount 컨테이너 실행

```powershell
docker run -d `
    --name nginx-bind-practice `
    -p 8082:80 `
    -v "${PWD}\site:/usr/share/nginx/html:ro" `
    nginx:alpine
```

한 줄로 실행하면 다음과 같습니다.

```powershell
docker run -d --name nginx-bind-practice -p 8082:80 -v "${PWD}\site:/usr/share/nginx/html:ro" nginx:alpine
```

| 구성 | 의미 |
|---|---|
| `${PWD}\site` | 현재 프로젝트의 `site` 디렉터리 |
| `/usr/share/nginx/html` | 컨테이너의 Nginx 웹 루트 |
| `:ro` | 컨테이너에서는 읽기 전용으로 연결 |
| `8082:80` | Bind Mount 검증용 호스트 포트 |

웹 서버는 파일을 읽기만 하면 되므로 `:ro`로 연결했습니다. 컨테이너에서 실수하거나 침해가 발생해도 호스트 소스를 수정하지 못하도록 범위를 줄이는 설정입니다.

### 19.3 Mount 설정 확인

```powershell
$mounts = (docker inspect nginx-bind-practice | ConvertFrom-Json)[0].Mounts
$mounts | Format-List Type, Source, Destination, RW
```

확인 결과:

```text
Type        : bind
Source      : C:\cpp\docker-web-practice\site
Destination : /usr/share/nginx/html
RW          : False
```

- `Type : bind`: 호스트 경로를 직접 연결
- `Source`: Windows의 실제 폴더
- `Destination`: 컨테이너 안에서 보이는 위치
- `RW : False`: 읽기 전용

![Bind Mount 실행과 설정](<images/bind mount 코드 로그.png>)

### 19.4 호스트 파일 수정 즉시 반영

`site/index.html`의 배지와 설명을 다음과 같이 수정했습니다.

```html
<span class="badge">NGINX + BIND MOUNT</span>
<p>호스트에서 수정한 HTML이 Bind Mount를 통해 즉시 반영되었습니다.</p>
```

컨테이너를 재시작하거나 이미지를 다시 빌드하지 않은 상태에서 확인했습니다.

```powershell
curl.exe -s http://localhost:8082 |
    Select-String -SimpleMatch "NGINX + BIND MOUNT"

docker ps --filter name=nginx-bind-practice
```

HTML 변경 내용이 출력되었고 컨테이너 생성 시각은 그대로인 채 `Up` 상태가 유지되어 실시간 반영을 검증했습니다.

![Bind Mount 변경 내용 검증](<images/bindmount html변경후.png>)

![Bind Mount 변경 후 웹페이지](<images/bindmount 웹페이지 변경후.png>)

### 19.5 이미지 COPY와 Bind Mount 비교

```powershell
curl.exe -s http://localhost:8081 |
    Select-String -SimpleMatch "NGINX + DOCKER"

curl.exe -s http://localhost:8082 |
    Select-String -SimpleMatch "NGINX + BIND MOUNT"
```

- `8081`: 이미지 Build 당시 `COPY`된 기존 파일
- `8082`: 호스트의 현재 `site/index.html`을 직접 연결한 파일

같은 호스트 파일을 수정했지만 이미지 기반 컨테이너는 바뀌지 않고 Bind Mount 컨테이너만 바뀌었습니다.

`Select-String`은 기본적으로 정규식을 사용합니다. 처음에는 `+`가 ‘앞 문자의 1회 이상 반복’을 뜻하는 정규식 기호로 처리되어 일치 결과가 나오지 않았습니다. `-SimpleMatch`를 추가하여 `+`를 평범한 문자 그대로 검색했습니다.

---

## 20. Docker Volume

### 20.1 목적

컨테이너의 기본 쓰기 계층에만 저장된 데이터는 컨테이너가 삭제되면 함께 사라집니다. Docker Volume은 컨테이너와 독립된 Docker 관리 저장 공간이므로 컨테이너 교체 후에도 데이터를 유지할 수 있습니다.

### 20.2 Volume 생성

```powershell
docker volume create docker-web-practice-data
docker volume ls --filter name=docker-web-practice-data
```

`local` Driver를 사용하는 `docker-web-practice-data`라는 이름의 Volume이 생성되었습니다.

### 20.3 첫 번째 컨테이너에서 데이터 저장

```powershell
docker run -d `
    --name volume-practice-1 `
    -v docker-web-practice-data:/data `
    ubuntu:latest sleep infinity
```

- `docker-web-practice-data:/data`: 이름 있는 Volume을 컨테이너 `/data`에 연결
- `sleep infinity`: 검증하는 동안 컨테이너가 종료되지 않도록 주 프로세스를 계속 실행

```powershell
docker exec volume-practice-1 `
    sh -c "echo Persistent-Volume-Data > /data/proof.txt"

docker exec volume-practice-1 cat /data/proof.txt
```

`Persistent-Volume-Data`가 출력되어 Volume에 파일을 저장하고 읽을 수 있음을 확인했습니다.

![Volume 생성 및 데이터 저장](<images/volume생성확인데이터저장확인.png>)

### 20.4 첫 번째 컨테이너 삭제

```powershell
docker rm -f volume-practice-1
docker ps -a --filter name=volume-practice-1
docker volume ls --filter name=docker-web-practice-data
```

- `docker rm -f`: 실행 중인 컨테이너를 정지하고 삭제
- 컨테이너 목록에서는 `volume-practice-1`이 사라짐
- Volume 목록에는 `docker-web-practice-data`가 남아 있음

![첫 번째 컨테이너 삭제와 Volume 확인](<images/volume삭제데이터검증.png>)

### 20.5 두 번째 컨테이너에서 기존 데이터 확인

```powershell
docker run -d `
    --name volume-practice-2 `
    -v docker-web-practice-data:/data `
    ubuntu:latest sleep infinity

docker exec volume-practice-2 cat /data/proof.txt
```

새 컨테이너에서도 기존의 `Persistent-Volume-Data`가 출력되었습니다. 따라서 데이터가 첫 번째 컨테이너가 아니라 독립된 Volume에 저장되었다는 사실을 증명했습니다.

```powershell
$volumeMount = (docker inspect volume-practice-2 | ConvertFrom-Json)[0].Mounts
$volumeMount | Format-List Type, Name, Destination, RW
```

확인 결과:

```text
Type        : volume
Name        : docker-web-practice-data
Destination : /data
RW          : True
```

![새 컨테이너에서 Volume 데이터 확인](<images/volume삭제후 데이터 있는지 확인.png>)

---

## 21. Bind Mount와 Docker Volume 비교

| 비교 항목 | Bind Mount | Docker Volume |
|---|---|---|
| 저장 위치 선택 | 사용자가 호스트 경로 직접 지정 | Docker가 관리 |
| 이번 실습 Source | `C:\cpp\docker-web-practice\site` | `docker-web-practice-data` |
| 컨테이너 경로 | `/usr/share/nginx/html` | `/data` |
| 주요 목적 | 개발 소스 즉시 반영 | DB·업로드 파일 등 영속 데이터 |
| 호스트에서 직접 수정 | 쉬움 | 일반적으로 Docker를 통해 관리 |
| 컨테이너 삭제 후 데이터 | 호스트 파일이므로 유지 | Volume이 독립적으로 유지 |
| 이식성 | 호스트 경로에 의존 | Docker 명령으로 관리하기 쉬움 |

이번 실습에서는 Bind Mount로 ‘이미지를 다시 빌드하지 않아도 소스가 즉시 바뀌는 것’을 증명했고, Volume으로 ‘컨테이너를 삭제하고 새로 만들어도 데이터가 남는 것’을 증명했습니다.

---

## 22. 브랜치와 Pull Request

### 22.1 프로젝트 파일 커밋 및 Push

```powershell
git add Dockerfile .dockerignore site/
git status
git commit -m "Add custom Nginx Docker practice"
git push origin main
```

`git status`에서 새 파일이 `Changes to be committed`로 변경된 것을 확인한 뒤 커밋했습니다. Push 후 로컬 `main`과 `origin/main`이 같은 상태가 되었습니다.

![Docker 프로젝트 파일 스테이징](<images/git 파일 올리기2.png>)

![Docker 프로젝트 파일 커밋](<images/git파일올리기3.png>)

![Docker 프로젝트 파일 Push](<images/깃 파일올리기 4.png>)

### 22.2 문서 브랜치 생성

```powershell
git switch -c docs/readme
git status
git branch
```

- `switch`: 작업 브랜치 전환
- `-c`: 새 브랜치를 생성하면서 전환
- `* docs/readme`: 현재 작업 브랜치 표시

```powershell
git push -u origin docs/readme
git branch -vv
```

`origin/docs/readme`가 표시되어 로컬 문서 브랜치와 GitHub 원격 브랜치가 연결된 것을 확인했습니다.

![docs/readme 브랜치 생성과 Push](<images/깃 branch 올렸다.png>)

### 22.3 Pull Request 및 Merge

README와 검증 이미지를 커밋하고 `docs/readme`에 Push한 뒤 GitHub에서 다음 순서로 진행합니다.

1. Base 브랜치가 `main`인지 확인
2. Compare 브랜치가 `docs/readme`인지 확인
3. 변경 파일과 내용을 검토
4. Pull Request 생성
5. Merge Pull Request 실행
6. 로컬에서 `main`으로 이동 후 최신 내용 받기

```powershell
git switch main
git pull origin main
```

### 실제 수행 결과

- Pull Request 번호: `#1`
- Base 브랜치: `main`
- Compare 브랜치: `docs/readme`
- 포함된 커밋: 1개
- 변경 파일: 54개
- 충돌 여부: 없음
- Merge 커밋: `c35787c`

`docs/readme`의 README와 검증 이미지가 Pull Request를 통해 `main`에 정상적으로 Merge되었습니다.

![Pull Request 생성 및 검토](<images/pr화면로그.png>)

![Pull Request Merge 완료](<images/merge화면2.png>)

---

## 23. 트러블슈팅

### 23.1 `git git config` 오타

**문제**

```powershell
git git config --global --get user.name
```

```text
git: 'git' is not a git command.
```

**원인**  
명령어 맨 앞의 `git`을 두 번 입력했습니다. Git은 두 번째 `git`을 하위 명령으로 해석했지만 그런 명령은 존재하지 않습니다.

**해결**

```powershell
git config --global --get user.name
```

### 23.2 `git remove -v` 오타

**문제**

```powershell
git remove -v
```

```text
git: 'remove' is not a git command.
```

**원인**  
원격 저장소는 영어 단어 `remove`가 아니라 Git 하위 명령 `remote`로 관리합니다.

**해결**

```powershell
git remote -v
```

### 23.3 PowerShell에서 README 한글 깨짐

**문제**  
VS Code에서는 정상인 README 한글이 `Get-Content README.md`에서 깨져 출력되었습니다.

**원인**  
Windows PowerShell 5.1이 UTF-8 파일을 올바른 인코딩으로 해석하지 못했습니다.

**해결**

```powershell
Get-Content README.md -Encoding UTF8
```

파일 손상이 아니라 출력 인코딩 문제임을 확인했습니다.

### 23.4 `docker server`는 존재하지 않는 명령

**문제**

```powershell
docker server
```

```text
docker: unknown command: docker server
```

**원인**  
Docker Server 정보를 확인하는 하위 명령의 이름을 잘못 추측했습니다.

**해결**

```powershell
docker version
```

`Client`와 `Server` 정보가 함께 출력되어 Engine 연결까지 확인할 수 있었습니다.

### 23.5 Docker Inspect `--format` 인용부호 오류

**문제**

```text
template parsing error: function "org" not defined
```

**원인**  
PowerShell과 Docker Go Template에서 따옴표가 중첩되며 Label 이름이 문자열이 아닌 함수처럼 해석되었습니다.

**해결**  
복잡한 인용부호를 계속 수정하는 대신 Docker JSON 출력을 PowerShell 객체로 변환했습니다.

```powershell
$config = (docker image inspect docker-web-practice:1.0 | ConvertFrom-Json)[0].Config
$config.Labels | Format-List
```

![Docker Inspect 인용부호 오류](<images/이미지설정확인오류.png>)

### 23.6 호스트 8080 포트 중복

**문제**  
새 Nginx 컨테이너에 8080 포트를 사용하려 했지만 기존 `bind-test` 컨테이너가 사용 중이었습니다.

**확인**

```powershell
docker ps --filter publish=8080 --format "table {{.Names}}\t{{.Ports}}"
```

**해결**  
기존 컨테이너를 임의로 삭제하지 않고 새 컨테이너에 8081, Bind Mount 컨테이너에 8082 포트를 사용했습니다.

### 23.7 Nginx `favicon.ico` 404

**문제**

```text
GET /favicon.ico HTTP/1.1 404
```

**원인**  
브라우저가 주소창 아이콘을 자동 요청했지만 `site/`에 favicon 파일이 없었습니다.

**판단**  
메인 요청 `GET /`는 `200`이므로 웹 서비스 실패가 아닙니다. favicon을 추가하거나 이 요청을 무시할 수 있습니다.

### 23.8 `Select-String`에서 `+`가 검색되지 않음

**문제**

```powershell
Select-String "NGINX + DOCKER"
```

문자열이 페이지에 존재하지만 결과가 출력되지 않았습니다.

**원인**  
`Select-String`이 `+`를 정규식 특수기호로 해석했습니다.

**해결**

```powershell
Select-String -SimpleMatch "NGINX + DOCKER"
```

`-SimpleMatch`로 정규식이 아닌 일반 문자열 검색을 수행했습니다.

### 23.9 컨테이너 종료 코드 137

**문제**  
`docker stop` 후 컨테이너가 `Exited (137)`로 표시되었습니다.

**원인 해석**  
프로세스가 정상 종료 코드 0으로 끝난 것이 아니라 `SIGKILL(9)`로 강제 종료되었습니다. 신호 종료 코드는 관례적으로 `128 + 9 = 137`입니다.

---

## 24. 보안 및 개인정보 점검

공개 GitHub 저장소에는 누구나 파일과 커밋을 볼 수 있으므로 다음 항목을 확인했습니다.

- 실제 Git 이메일 주소는 README에서 `<MASKED_EMAIL>`로 표시
- `docker info`에 출력된 `C:\Users\사용자명` 경로가 보이는 전체 캡처는 공개 문서에서 제외
- 비밀번호, GitHub Token, SSH Private Key를 저장소에 추가하지 않음
- `.git` 디렉터리를 Docker Build Context에서 제외
- 웹 소스는 Bind Mount에서 `:ro`로 연결

민감정보가 포함된 파일은 커밋 이후 삭제하는 것보다 처음부터 `git add`하지 않는 것이 중요합니다. 이미 커밋된 비밀값은 파일만 삭제해도 Git 이력에 남을 수 있으므로 즉시 자격 증명을 폐기하고 이력 정리가 필요합니다.

---

## 25. 평가자용 재현 방법

Docker Desktop의 Engine이 실행 중인 상태에서 다음 명령을 수행합니다.

```powershell
git clone https://github.com/kahanis-lab/docker-web-practice.git
cd docker-web-practice
docker build -t docker-web-practice:1.0 .
docker run -d --name docker-web-practice-demo -p 8081:80 docker-web-practice:1.0
curl.exe -I http://localhost:8081
```

브라우저에서 다음 주소로 접속합니다.

```text
http://localhost:8081
```

정상 기준:

- `docker build` 성공
- `docker ps`에서 컨테이너 상태가 `Up`
- `curl.exe -I` 결과가 `HTTP/1.1 200 OK`
- 브라우저에서 Nginx 커스텀 페이지 출력

8081 포트가 이미 사용 중이라면 `-p 8083:80`처럼 왼쪽 호스트 포트만 다른 번호로 변경할 수 있습니다.

---

## 26. 학습 내용 정리

### Dockerfile은 무엇인가?

Docker 이미지를 어떤 베이스에서 시작하고, 어떤 파일을 넣으며, 어떤 설정으로 실행할지를 코드로 기록한 제작 설명서입니다. Dockerfile 자체가 실행 중인 환경은 아니며, `docker build`를 거쳐 이미지가 만들어집니다.

### 이미지와 컨테이너는 무엇이 다른가?

이미지는 실행 환경을 저장한 읽기 전용 설계도이고, 컨테이너는 그 이미지로 만든 실제 실행 인스턴스입니다. 같은 이미지에서 여러 컨테이너를 만들 수 있습니다.

### 포트 매핑은 왜 필요한가?

컨테이너의 네트워크는 호스트와 분리되어 있으므로 Nginx가 컨테이너 내부 80번 포트에서 대기해도 Windows 브라우저가 자동으로 접근할 수 없습니다. `-p 8081:80`을 사용해 Windows의 8081번 요청을 컨테이너 80번으로 전달했습니다.

### Bind Mount는 언제 사용하는가?

개발 중 호스트의 소스 파일을 저장할 때 컨테이너가 즉시 같은 파일을 읽게 하고 싶을 때 사용합니다. 이번 실습에서는 이미지 재빌드와 컨테이너 재시작 없이 HTML 변경이 반영되는 것을 확인했습니다.

### Docker Volume은 언제 사용하는가?

컨테이너가 교체되거나 삭제되어도 유지되어야 하는 데이터를 저장할 때 사용합니다. 데이터베이스, 업로드 파일, 애플리케이션 상태 저장에 적합합니다.

### `attach`보다 `exec`를 자주 사용하는 이유는 무엇인가?

`attach`는 주 프로세스에 직접 연결되므로 `exit`가 컨테이너 종료로 이어질 수 있습니다. `exec`는 별도 프로세스를 추가하므로 점검용 Bash를 종료해도 주 프로세스와 컨테이너는 계속 실행됩니다.

### Git과 GitHub는 무엇이 다른가?

Git은 로컬 컴퓨터에서 파일 버전을 관리하는 도구이고, GitHub는 Git 저장소를 원격으로 보관하고 Pull Request, Review 등 협업 기능을 제공하는 서비스입니다. `git commit`은 로컬 기록이고 `git push`를 해야 GitHub에 전송됩니다.

### 브랜치와 Pull Request는 왜 사용하는가?

브랜치는 안정적인 `main`을 직접 수정하지 않고 독립된 작업선을 만들기 위해 사용합니다. Pull Request는 브랜치의 변경 내용을 검토하고 논의한 뒤 `main`에 합치기 위한 협업 절차입니다.

---

## 27. 선택적 정리 명령

검증이 모두 끝난 뒤 필요한 경우 다음처럼 실습 리소스를 정리할 수 있습니다.

```powershell
docker stop nginx-web-practice nginx-bind-practice volume-practice-2
docker rm nginx-web-practice nginx-bind-practice volume-practice-2
docker volume rm docker-web-practice-data
```

Volume 삭제는 저장된 데이터도 제거하므로 데이터 영속성 검증과 제출이 모두 끝난 뒤 실행해야 합니다. 이 프로젝트에서는 검증 자료 보존을 위해 자동으로 삭제하지 않았습니다.

---

## 28. 결론

이번 실습에서는 단순히 Docker 명령어를 실행하는 것에 그치지 않고, 각 단계의 상태를 다음 명령으로 다시 검증했습니다.

- `git status`, `git log`, `git remote -v`: Git 상태와 원격 연결 검증
- `docker version`, `docker info`: CLI와 Engine 연결 검증
- `docker ps`, `docker ps -a`: 실행·종료 상태 비교
- `docker image inspect`, `docker inspect`: 이미지와 Mount 설정 검증
- `curl.exe`: 실제 HTTP 응답 검증
- `docker logs`: Nginx 요청과 오류 검증
- 컨테이너 삭제 전후 파일 확인: Docker Volume 영속성 검증

이를 통해 Git/GitHub 버전 관리부터 Linux CLI, Docker 이미지 제작, 네트워크 포트, 호스트 파일 연결, 영속 데이터 저장까지 개발 워크스테이션의 기본 흐름을 직접 구성하고 설명할 수 있게 되었습니다.


## 29. 보너스 과제

필수 실습을 완료한 뒤 Docker Compose, 환경변수 관리, GitHub SSH 인증을 추가로 실습하였다. 단순히 명령을 실행하는 데 그치지 않고 Compose 파일의 문법 검사, 멀티 컨테이너 네트워크, 환경변수 주입, 민감 파일 제외, SSH 인증과 원격 저장소 조회까지 각각 검증하였다.

### 29.1 수행 결과 요약

| 보너스 항목 | 상태 | 검증 방법 |
|---|---|---|
| Docker Compose 설치 확인 | 완료 | `docker compose version` |
| Compose 단일 서비스 | 완료 | Nginx Build 및 8083 포트 HTTP 200 확인 |
| Compose 멀티 컨테이너 | 완료 | `web`, `env-check` 두 서비스가 `Up`인지 확인 |
| Compose 네트워크 | 완료 | 동일한 기본 네트워크에 두 컨테이너가 연결됐는지 확인 |
| 환경변수 주입 | 완료 | `.env` 값과 컨테이너 내부 `printenv` 결과 비교 |
| 환경변수 파일 보호 | 완료 | `.gitignore`와 `git check-ignore`로 `.env` 제외 확인 |
| Compose 운영 명령 | 완료 | `config`, `up`, `ps`, `logs`, `exec`, `down` 사용 |
| GitHub SSH 키 | 완료 | 공개 키 등록 후 `ssh -T git@github.com` 인증 성공 |
| Git 원격 주소 SSH 전환 | 완료 | `git remote -v`, `git ls-remote origin HEAD` 확인 |

---

### 29.2 Docker Compose란?

`docker run`은 컨테이너를 실행할 때마다 이미지, 컨테이너 이름, 포트, 환경변수 등의 옵션을 명령줄에 직접 작성한다. Docker Compose는 이러한 실행 설정을 `compose.yaml` 파일에 코드로 기록하고, 하나 이상의 컨테이너를 같은 프로젝트 단위로 관리하는 도구이다.

이번 실습에서는 다음과 같은 차이를 확인하였다.

| 직접 실행 | Compose 실행 |
|---|---|
| 긴 `docker run` 옵션을 매번 입력 | 실행 설정을 `compose.yaml`에 저장 |
| 컨테이너를 개별적으로 관리 | 여러 서비스를 프로젝트 단위로 관리 |
| 네트워크를 직접 만들고 연결할 수 있음 | 기본 네트워크를 자동 생성하고 서비스들을 연결 |
| 실행 명령만 보면 구성을 파악하기 어려움 | YAML 파일을 통해 실행 구성을 재현 가능 |

Compose 버전과 보너스 작업 브랜치를 확인하였다.

```powershell
git switch -c bonus/compose-env-ssh
git branch --show-current
docker compose version
```

실행 환경에서는 Docker Compose `v5.3.1`이 확인되었다.

![Compose 준비 및 버전 확인](<images/bonus1.png>)

---

### 29.3 Compose 단일 서비스 실행

처음에는 Nginx 웹 서버 하나만 Compose로 실행하였다.

```yaml
name: docker-web-practice

services:
  web:
    build:
      context: .
      dockerfile: Dockerfile
    image: docker-web-practice:compose
    container_name: compose-web-practice
    ports:
      - "8083:80"
```

각 항목의 역할은 다음과 같다.

- `name`: Compose 프로젝트 이름
- `services`: 실행할 서비스 목록
- `web`: 서비스 식별 이름
- `build.context: .`: 현재 프로젝트 폴더를 Build Context로 사용
- `dockerfile: Dockerfile`: 사용할 Dockerfile 지정
- `image`: Build 결과 이미지의 이름과 태그
- `container_name`: 실제 생성될 컨테이너 이름
- `8083:80`: Windows의 8083번 포트를 컨테이너의 80번 포트에 연결

YAML은 들여쓰기가 구조를 나타내므로 탭 대신 공백을 사용하고 같은 계층의 들여쓰기를 일치시켜야 한다.

Compose가 YAML을 정상적으로 해석하는지 먼저 검사하였다.

```powershell
docker compose config
```

`docker compose config` 결과에서 호스트 포트 `8083`, 컨테이너 포트 `80`, 자동 생성될 `docker-web-practice_default` 네트워크를 확인하였다.

이미지를 Build하고 컨테이너를 백그라운드에서 실행하였다.

```powershell
docker compose up -d --build
docker compose ps
```

- `up`: Compose 파일에 정의된 서비스를 생성하고 실행
- `-d`: 터미널을 계속 사용할 수 있도록 백그라운드 실행
- `--build`: 컨테이너 실행 전에 Dockerfile로 이미지 Build
- `ps`: 현재 Compose 프로젝트에 속한 서비스 상태 확인

![Compose 단일 서비스 Build](<images/compose build 결과.png>)

![Compose 단일 서비스 상태](<images/compose build결과 2.png>)

HTTP 헤더를 요청하여 실제 웹 서버 응답을 확인하였다.

```powershell
curl.exe -I http://localhost:8083
```

결과에서 `HTTP/1.1 200 OK`와 `Server: nginx`가 출력되어 포트 매핑과 Nginx 실행이 모두 정상임을 확인하였다.

![Compose HTTP 200 응답](<images/compose curl.png>)

![Compose 단일 서비스 웹페이지](<images/bonus compose 웹.png>)

웹페이지에 이전 Bind Mount 실습 문구가 표시되었지만, 이 Compose 설정에는 Bind Mount가 없다. 이전 실습에서 수정한 `site/index.html`이 Docker Build 과정의 `COPY` 명령으로 이미지에 포함된 것이다. 따라서 표시된 HTML 문구와 현재 컨테이너의 Mount 방식은 구분해서 해석해야 한다.

---

### 29.4 환경변수와 멀티 컨테이너 구성

단일 `web` 서비스에 Ubuntu 기반의 `env-check` 서비스를 추가하였다. 또한 호스트 포트와 메시지를 코드에 고정하지 않고 `.env`에서 가져오도록 변경하였다.

최종 `compose.yaml`은 다음과 같다.

```yaml
name: docker-web-practice

services:
  web:
    build:
      context: .
      dockerfile: Dockerfile
    image: docker-web-practice:compose
    container_name: compose-web-practice
    ports:
      - "${WEB_PORT}:80"

  env-check:
    image: ubuntu:latest
    container_name: compose-env-practice
    environment:
      PRACTICE_MESSAGE: ${PRACTICE_MESSAGE}
    command:
      - sh
      - -c
      - 'echo "Environment value: $$PRACTICE_MESSAGE" && sleep infinity'
```

환경변수 처리 과정은 다음과 같다.

1. Compose가 프로젝트 폴더의 `.env` 파일을 읽는다.
2. `${WEB_PORT}`와 `${PRACTICE_MESSAGE}`를 `.env` 값으로 치환한다.
3. `PRACTICE_MESSAGE`를 `env-check` 컨테이너의 환경변수로 전달한다.
4. `$$PRACTICE_MESSAGE`의 `$$`는 Compose 단계에서 `$` 하나로 전달된다.
5. 컨테이너 내부 `sh`가 `$PRACTICE_MESSAGE`를 실제 환경변수 값으로 해석한다.
6. `sleep infinity`가 프로세스를 유지하여 컨테이너가 바로 종료되지 않게 한다.

실습용 `.env`에는 다음 값을 사용하였다.

```dotenv
WEB_PORT=8084
PRACTICE_MESSAGE=Environment variable loaded successfully
```

`.env`는 실행 환경마다 달라질 수 있고 실제 프로젝트에서는 비밀번호나 API 키가 포함될 수 있으므로 Git에서 제외하였다. 대신 필요한 변수 이름을 알려주는 `.env.example`을 작성하였다.

```dotenv
WEB_PORT=8084
PRACTICE_MESSAGE=Change this message
```

`.gitignore`에는 다음 규칙을 추가하였다.

```gitignore
.env
.env.*
!.env.example
```

- `.env`: 실제 환경변수 파일 제외
- `.env.*`: 환경별 추가 파일 제외
- `!.env.example`: 공유 가능한 예제 파일은 예외적으로 Git에 포함

#### 환경변수 미적용 오류

처음에는 파일을 생성하고 편집기에서 저장하지 않은 상태로 `docker compose config`를 실행하여 다음 경고가 발생하였다.

```text
The "WEB_PORT" variable is not set. Defaulting to a blank string.
The "PRACTICE_MESSAGE" variable is not set. Defaulting to a blank string.
```

또한 `.gitignore`가 저장되지 않아 `git status`에서 `.env`가 추적되지 않은 파일로 표시되었다. 파일 내용을 작성한 뒤 모든 파일을 저장하고 다시 검증하여 해결하였다.

![환경변수 파일 미저장 오류](<images/보너스 환경설정보호2.png>)

다음 명령으로 최종 설정과 제외 규칙을 확인하였다.

```powershell
docker compose config
git check-ignore -v .env
git status --short -- compose.yaml .env .env.example .gitignore
```

`docker compose config`에서 `published: "8084"`와 환경변수 값이 출력되었으며, `git check-ignore` 결과에서 `.gitignore:1:.env` 규칙이 적용된 것을 확인하였다. `git status`에는 `.env`가 나타나지 않고 `compose.yaml`, `.env.example`, `.gitignore`만 나타났다.

![환경변수 적용 및 Git 제외 확인](<images/보너스 환경설정보호4.png>)

---

### 29.5 멀티 컨테이너와 Compose 네트워크 검증

변경된 설정을 적용하였다.

```powershell
docker compose up -d --build
docker compose ps
```

`web`과 `env-check` 두 서비스가 모두 `Up` 상태인 것을 확인하였다.

![Compose 멀티 컨테이너 Build](<images/보너스 네트워크 빌드.png>)

![Compose 멀티 컨테이너 상태](<images/보너스 네트워크 docker ps.png>)

환경변수 전달은 로그와 컨테이너 내부 조회를 각각 사용해 검증하였다.

```powershell
docker compose logs env-check
docker compose exec env-check printenv PRACTICE_MESSAGE
```

두 명령 모두 다음 값을 출력하였다.

```text
Environment variable loaded successfully
```

Compose가 자동 생성한 기본 네트워크의 컨테이너 목록을 확인하였다.

```powershell
docker network inspect docker-web-practice_default --format '{{range .Containers}}{{println .Name}}{{end}}'
```

결과에 다음 두 컨테이너가 모두 출력되었다.

```text
compose-env-practice
compose-web-practice
```

따라서 서로 다른 두 서비스가 같은 Compose 네트워크에 연결된 것을 확인하였다. 같은 Compose 네트워크의 컨테이너는 일반적으로 IP 주소를 직접 기억하는 대신 서비스 이름을 통해 서로를 찾을 수 있다.

![환경변수와 Compose 네트워크 검증](<images/보너스 네트워크 exec inspect.png>)

브라우저에서 `.env`로 지정한 `http://localhost:8084`에 접속하여 웹 서버도 정상적으로 동작함을 확인하였다.

![환경변수 포트 웹페이지](<images/보너스 네트워크결과웹.png>)

---

### 29.6 Compose 종료와 리소스 상태 확인

Compose가 생성한 리소스를 프로젝트 단위로 정리하였다.

```powershell
docker compose down
docker compose ps
docker network ls --filter name=docker-web-practice_default
docker images docker-web-practice
```

`docker compose down` 결과:

- `compose-web-practice` 컨테이너 제거
- `compose-env-practice` 컨테이너 제거
- `docker-web-practice_default` 네트워크 제거
- Build된 `docker-web-practice:compose` 이미지는 유지

즉, `down`은 기본적으로 Compose 컨테이너와 네트워크를 정리하지만 Build한 이미지까지 자동 삭제하지는 않는다.

![Compose 종료와 이미지 유지 확인](<images/보너스 컴포즈종료.png>)

---

### 29.7 HTTPS와 SSH 인증 차이

처음 저장소의 `origin`은 HTTPS 주소를 사용하였다.

```text
https://github.com/kahanis-lab/docker-web-practice.git
```

보너스 실습에서는 GitHub 계정에 SSH 공개 키를 등록하고 다음 주소로 변경하였다.

```text
git@github.com:kahanis-lab/docker-web-practice.git
```

| HTTPS | SSH |
|---|---|
| HTTPS 프로토콜 사용 | SSH 프로토콜 사용 |
| Git Credential Manager, Token 등으로 인증 | 공개 키와 개인 키 쌍으로 인증 |
| 원격 주소가 `https://...` 형태 | 원격 주소가 `git@github.com:...` 형태 |
| 자격 증명 관리자가 로그인을 보조 | GitHub에 공개 키를 등록하고 개인 키로 본인임을 증명 |

SSH 개인 키와 공개 키의 역할은 다음과 같다.

- 개인 키 `id_ed25519`: 사용자 PC에만 보관하며 절대 공개하거나 커밋하지 않음
- 공개 키 `id_ed25519.pub`: GitHub 계정에 등록 가능
- Fingerprint: 공개 키를 짧게 식별하기 위한 SHA256 지문
- `known_hosts`: 접속한 원격 서버의 신원을 저장하여 다음 접속에서 같은 서버인지 확인

---

### 29.8 GitHub SSH 키 생성 및 등록

기존 SSH 폴더와 키가 없는 것을 확인한 뒤 ED25519 키를 생성하였다.

```powershell
ssh -V
Test-Path "$env:USERPROFILE\.ssh"
Get-ChildItem "$env:USERPROFILE\.ssh" -Force -ErrorAction SilentlyContinue
ssh-keygen -t ed25519 -C "windows-docker-practice"
```

`id_ed25519` 개인 키와 `id_ed25519.pub` 공개 키가 생성되었다. 공개 키만 GitHub의 `Settings > SSH and GPG keys > New SSH key`에 `Authentication Key`로 등록하였다.

![GitHub SSH 공개 키 등록](<images/보너스 키 추가1.png>)

#### 잘못된 공개 키 붙여넣기 오류

처음에는 GitHub Key 입력란에 공개 키 전체가 아닌 다른 클립보드 내용이 들어가 다음 오류가 발생하였다.

```text
Key is invalid. You must supply a key in OpenSSH public key format
```

GitHub에 등록해야 하는 공개 키는 다음과 같은 한 줄 형식이다.

```text
ssh-ed25519 <PUBLIC_KEY_DATA> windows-docker-practice
```

SHA256 지문, randomart, 개인 키 또는 `Ctrl+V`라는 글자를 입력하는 것이 아니다. 다음 명령으로 `.pub` 파일 전체를 클립보드에 넣은 직후 GitHub 입력란에서 실제 키보드 단축키 `Ctrl+V`를 사용하여 해결하였다.

```powershell
$publicKey = (Get-Content "$env:USERPROFILE\.ssh\id_ed25519.pub" -Raw).Trim()
Set-Clipboard -Value $publicKey
```

공개 키는 GitHub 등록에 사용할 수 있지만 개인 키 `id_ed25519`의 내용은 어떤 문서, 로그, 스크린샷에도 포함하지 않았다.

---

### 29.9 SSH 인증과 원격 저장소 전환 검증

GitHub SSH 인증을 테스트하였다.

```powershell
ssh -T git@github.com
```

첫 접속에서는 GitHub 서버의 Fingerprint를 확인하고 `yes`를 입력하여 `known_hosts`에 등록하였다. 이후 다음 성공 문구를 확인하였다.

```text
Hi kahanis-lab! You've successfully authenticated, but GitHub does not provide shell access.
```

GitHub가 일반 서버 셸을 제공하지 않으므로 명령이 종료될 때 터미널에서 실패 표시가 나타날 수 있지만, `successfully authenticated`는 SSH 사용자 인증이 성공했다는 의미이다.

원격 저장소 주소를 HTTPS에서 SSH로 변경하였다.

```powershell
git remote -v
git remote set-url origin git@github.com:kahanis-lab/docker-web-practice.git
git remote -v
git ls-remote origin HEAD
```

변경 후 Fetch와 Push 주소가 모두 다음과 같이 출력되었다.

```text
origin  git@github.com:kahanis-lab/docker-web-practice.git (fetch)
origin  git@github.com:kahanis-lab/docker-web-practice.git (push)
```

`git ls-remote origin HEAD`가 원격 저장소의 HEAD 커밋 해시를 반환하여 SSH를 통한 실제 원격 읽기까지 정상임을 확인하였다.

![GitHub SSH 인증 및 원격 연결 검증](<images/보너스 키확인1.png>)

---

### 29.10 보안 점검

보너스 실습에서 다음 보안 원칙을 적용하였다.

- `.env`는 `.gitignore`에 추가하여 Git에서 제외
- 공유가 필요한 변수 이름은 `.env.example`에 예시값으로 기록
- SSH 개인 키 `id_ed25519`은 사용자 PC의 `.ssh` 폴더에만 보관
- GitHub에는 공개 키 `id_ed25519.pub`만 등록
- 공개 README에는 개인 키, 비밀번호, 인증 코드, Token을 기록하지 않음
- 전체 공개 키 문자열 대신 등록 완료 화면과 SHA256 Fingerprint로 검증
- `git status`를 사용해 `.env`가 스테이징되지 않는지 확인

환경변수는 설정을 코드와 분리하는 데 유용하지만 환경변수 자체가 자동으로 암호화되는 것은 아니다. 실제 비밀번호와 API 키는 공개 저장소에 커밋하지 않고 GitHub Secrets, Docker Secrets 또는 별도의 비밀 관리 도구를 사용하는 것이 안전하다.

---

### 29.11 보너스 학습 정리

- Docker Compose는 여러 컨테이너의 실행 설정을 `compose.yaml`에 문서화한다.
- `docker compose config`는 실행 전에 YAML과 환경변수 치환 결과를 검사한다.
- Compose는 프로젝트 전용 기본 네트워크를 자동 생성한다.
- 같은 Compose 네트워크의 서비스는 서비스 이름을 기준으로 통신할 수 있다.
- `.env`를 사용하면 포트와 실행 설정을 Compose 파일에서 분리할 수 있다.
- `.env.example`은 실제 비밀값 없이 필요한 변수 형식을 협업자에게 전달한다.
- `docker compose up`, `ps`, `logs`, `exec`, `down`으로 여러 서비스를 일관되게 운영할 수 있다.
- HTTPS와 SSH는 모두 GitHub 원격 저장소에 접근할 수 있지만 인증 방법이 다르다.
- SSH에서는 공개 키를 GitHub에 등록하고 개인 키는 사용자 PC에만 보관한다.
- `ssh -T`와 `git ls-remote`를 함께 사용하여 인증 성공과 실제 저장소 접근을 각각 검증할 수 있다.

보너스 실습을 통해 단일 컨테이너 실행에서 더 나아가, 여러 서비스의 선언적 구성, 환경별 설정 분리, 네트워크 자동 구성, 안전한 GitHub 인증 흐름까지 직접 구성하고 설명할 수 있게 되었다.
