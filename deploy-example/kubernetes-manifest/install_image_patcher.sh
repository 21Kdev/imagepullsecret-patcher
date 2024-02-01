#!/bin/bash

# GitHub Raw 링크 설정
rawUrl="https://raw.githubusercontent.com/21Kdev/imagepullsecret-patcher/master/deploy-example/kubernetes-manifest/2_deployment.yaml"
echo "-------------------------------------------------------------------------------------"
echo ""
# 사용자 입력 받기
read -p "Docker Hub ID: " dockerHubId
read -p "Docker Hub Token: " dockerHubToken
read -p "Docker Hub Email: " dockerHubEmail

if [ -z "$dockerHubId" ] || [ -z "$dockerHubToken" ] || [ -z "$dockerHubEmail" ]; then
    echo "오류: Docker Hub ID 또는 Token 또는 Email이 누락되었습니다. 작업이 취소되었습니다."
    exit 1
fi

# 입력 값 확인 및 사용자 승인 요청
read -p "이 정보로 계속하시겠습니까? [Y/N] " confirmation

if [[ $confirmation =~ ^[Yy]$ ]]
then
    # .dockerconfigjson 생성 및 인코딩
    dockerConfigJson=$(cat <<EOF
    {
      "auths": {
        "https://index.docker.io/v1/": {
          "username": "$dockerHubId",
          "password": "$dockerHubToken",
          "email": "$dockerHubEmail"
        }
      }
    }
EOF
    )

    encodedDockerConfigJson=$(echo -n "$dockerConfigJson" | base64 -w 0)
    kubectl apply -f https://raw.githubusercontent.com/21Kdev/imagepullsecret-patcher/master/deploy-example/kubernetes-manifest/0_namespace.yaml
    kubectl apply -f https://raw.githubusercontent.com/21Kdev/imagepullsecret-patcher/master/deploy-example/kubernetes-manifest/1_rbac.yaml
    # GitHub Raw 링크로부터 YAML 파일 내용 가져오기, 수정 후 적용
    curl -s $rawUrl | sed "s/eyJhdXRocyI6eyJnY3IuaW8iOnsicGFzc3dvcmQiOiJ7XCJhdXRoXCI6e1wiZ2NyLmlvXCI6e1widXNlcm5hbWVcIjpcIl9qc29uX2tleVwiLFwicGFzc3dvcmRcIjpcInt9XCJ9fX0iLCJ1c2VybmFtZSI6Il9qc29uX2tleSJ9fX0=/$encodedDockerConfigJson/" | kubectl apply -f -
else
    echo "작업이 취소되었습니다."
fi
