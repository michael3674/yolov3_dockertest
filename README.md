# yolov3_dockertest

Docker 기반 YOLOv3(Darknet) 추론 예제입니다. 이미지 URL을 입력으로 받아 컨테이너 내부에서 다운로드한 뒤, YOLOv3로 탐지 결과(`predictions.jpg`)를 생성합니다. 기본 설정은 CPU 빌드입니다.

## 요구 사항
- Docker 설치
- (실행 시) 입력 이미지가 컨테이너 내부에서 `wget`으로 접근 가능한 URL이어야 함

## 프로젝트 구성
- `Dockerfile`: Darknet 클론 및 빌드, YOLOv3 가중치 다운로드, 실행 스크립트 설정
- `result_img/`: 호스트 측 결과 이미지를 모아두는 폴더(선택적으로 사용)

## 이미지 빌드
```bash
# 프로젝트 루트에서 실행
docker build -t yolov3_dockertest .
```

## 로컬 실행(빠른 시작)
```bash
# 컨테이너에 이름을 붙여 실행(복사 편의)
docker run --name yolov3_test yolov3_dockertest \
  https://upload.wikimedia.org/wikipedia/commons/4/45/A_small_cup_of_coffee.JPG

# 컨테이너 내부 생성 파일을 호스트로 복사
# 컨테이너 내부 경로: /opt/darknet/predictions.jpg
mkdir -p result_img
docker cp yolov3_test:/opt/darknet/predictions.jpg ./result_img/coffee.jpg

# 컨테이너 정리(선택)
docker rm yolov3_test
```

- 실행이 완료되면 `predictions.jpg`가 컨테이너 내부 `/opt/darknet`에 생성됩니다.
- 위 예시는 결과를 `result_img/coffee.jpg`로 복사합니다.
- 매 실행마다 `predictions.jpg`는 덮어써지므로, 호스트로 복사 시 파일명을 구분해 저장하세요.

## Docker Hub 배포(옵션)
이미지를 Docker Hub에 푸시하려면 아래를 참고하세요.
```bash
# 1) 태그 추가
docker tag yolov3_dockertest:latest michael3674/yolov3_dockertest:latest

# 2) 푸시
docker push michael3674/yolov3_dockertest:latest
```

## Docker Hub 이미지로 실행(옵션)
```bash
# 이미지를 직접 빌드하지 않고 Hub 이미지를 사용하는 경우
docker run --name yolov3_test michael3674/yolov3_dockertest:latest \
  https://upload.wikimedia.org/wikipedia/commons/4/45/A_small_cup_of_coffee.JPG

mkdir -p result_img
docker cp yolov3_test:/opt/darknet/predictions.jpg ./result_img/coffee.jpg

docker rm yolov3_test
```

## 컨테이너/결과 확인 팁
```bash
# 종료된 컨테이너 포함 목록
docker container ls -a

# 필요 시 특정 컨테이너에서 결과 복사 예시
docker cp <CONTAINER_ID>:/opt/darknet/predictions.jpg ./result_img/output.jpg

# 결과 미리보기(리눅스 데스크톱)
xdg-open ./result_img/output.jpg
```

## 참고/주의
- 본 Dockerfile은 CPU 전용 빌드입니다(GPU/CUDA 미포함). GPU 사용이 필요하면 Darknet의 CUDA/cuDNN 옵션을 켜도록 Dockerfile을 수정해야 합니다.
- 입력은 URL 한 개만 받습니다. 로컬 파일로 추론하려면, 이미지를 컨테이너로 복사하거나 볼륨 마운트 후 스크립트를 수정해 사용하세요.
- 빌드 시 Darknet 레포 및 YOLOv3 가중치가 인터넷에서 다운로드됩니다. 네트워크가 필요합니다.
