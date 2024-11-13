# 1. 베이스 이미지 설정
FROM tomcat:9.0

# 2. 작업 디렉토리 설정
WORKDIR /usr/local/tomcat

# 3. 애플리케이션 WAR 파일 복사
COPY target/myapp.war /usr/local/tomcat/webapps/

# 4. 포트 설정 (Tomcat 기본 포트)
EXPOSE 8080

# 5. Tomcat 실행
CMD ["catalina.sh", "run"]
