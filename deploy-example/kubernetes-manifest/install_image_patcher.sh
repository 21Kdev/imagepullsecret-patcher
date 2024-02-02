#!/bin/bash

# GitHub Raw 링크 설정
rawUrl="https://raw.githubusercontent.com/21Kdev/imagepullsecret-patcher/master/deploy-example/kubernetes-manifest/2_deployment.yaml"

# 사용자 입력 받기
echo "----------------------------------------------------------------------------------------"
read -p "Docker Hub ID: " dockerHubId
read -p "Docker Hub Token: " dockerHubToken
read -p "Docker Hub Email: " dockerHubEmail

if [ -z "$dockerHubId" ] || [ -z "$dockerHubToken" ] || [ -z "$dockerHubEmail" ]; then
  echo "오류: Docker Hub ID 또는 Token 또는 Email이 누락되었습니다. 작업이 취소되었습니다."
  exit 1
fi

# 입력 값 확인 및 사용자 승인 요청
echo ""
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

  master_node=$(kubectl get nodes --selector=node-role.kubernetes.io/control-plane= --output=jsonpath='{.items[0].metadata.name}')

  if [ -z "$master_node" ]; then
    echo "마스터 노드를 찾을 수 없습니다."
    exit 1
  fi

  kubectl taint nodes $master_node node-role.kubernetes.io/control-plane:NoSchedule-
		
  encodedDockerConfigJson=$(echo -n "$dockerConfigJson" | base64 -w 0)
  kubectl apply -f https://raw.githubusercontent.com/21Kdev/imagepullsecret-patcher/master/deploy-example/kubernetes-manifest/0_namespace.yaml
  kubectl apply -f https://raw.githubusercontent.com/21Kdev/imagepullsecret-patcher/master/deploy-example/kubernetes-manifest/1_rbac.yaml
  # GitHub Raw 링크로부터 YAML 파일 내용 가져오기, 수정 후 적용
  curl -s $rawUrl | sed "s/eyJhdXRocyI6eyJnY3IuaW8iOnsicGFzc3dvcmQiOiJ7XCJhdXRoXCI6e1wiZ2NyLmlvXCI6e1widXNlcm5hbWVcIjpcIl9qc29uX2tleVwiLFwicGFzc3dvcmRcIjpcInt9XCJ9fX0iLCJ1c2VybmFtZSI6Il9qc29uX2tleSJ9fX0=/$encodedDockerConfigJson/" | kubectl apply -f -
		
  # Deployment의 파드가 1/1이 되기를 기다립니다.
  echo -n "imagepullsecret-patcher pod 생성을 기다리는 중입니다"
  while true; do
    echo -ne "..."
    desired=$(kubectl get deployment imagepullsecret-patcher -n imagepullsecret-patcher --output=jsonpath='{.spec.replicas}')
    current=$(kubectl get deployment imagepullsecret-patcher -n imagepullsecret-patcher --output=jsonpath='{.status.readyReplicas}')
    if [ "$desired" -eq "$current" ]; then
      sleep 1
      break
    fi
    sleep 0.5	
    echo -ne "\b\b\b"
  done
  
  echo ""
  echo ""
  kubectl patch deployment imagepullsecret-patcher -n imagepullsecret-patcher --type='json' -p='[{"op": "replace", "path": "/spec/template/spec/hostNetwork", "value": false}]'
  kubectl patch deployment imagepullsecret-patcher -n imagepullsecret-patcher --type='json' -p='[{"op": "remove", "path": "/spec/template/spec/tolerations"}]'
  kubectl taint nodes $master_node node-role.kubernetes.io/control-plane:NoSchedule
else
  echo "작업이 취소되었습니다."
fi
