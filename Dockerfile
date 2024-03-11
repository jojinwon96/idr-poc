# 이미지의 기반이 될 이미지를 설정합니다.
FROM node:16.17

# 컨테이너 내에서 애플리케이션을 실행할 작업 디렉토리를 설정합니다.
WORKDIR /idr-poc

# package.json 및 package-lock.json을 복사
COPY package*.json ./

# locale setting 한글깨짐 방지
ENV LANG=C.UTF-8 \
    TZ="Asia/Seoul"

# vim 설치
RUN apt-get update && apt-get -y install vim nano net-tools psmisc rename

# 의존성을 설치
RUN npm install

# 호스트의 현재 디렉토리에 있는 모든 파일을 컨테이너의 작업 디렉토리로 복사합니다.
COPY . .

# 포트를 노출합니다.
EXPOSE 8060