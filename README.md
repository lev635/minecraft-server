# Minecraft Server on AWS
AWS 上に Minecraft のマルチプレイサーバーを構築します。
Terraform でリソースを定義しているため、誰でも同じ環境を構築できます。

## 構成
- **EC2**: サーバ本体
- **EBS**: セーブデータ保存場所

## セットアップ
1. Terraform と AWS CLI を導入してください。
2. EC2 を操作するための SSH キーペアを生成してください。
```sh
ssh-keygen -t rsa -b 4096
```
3. `infra/trraform.tfvars` に生成した鍵のパスを書いてください。
```hcl
ssh_public_key_path = "/home/lev635/.ssh/id_rsa.pub"
```
4. デプロイするとサーバが構築されます。
```sh
cd infra
terraform init
terraform apply
```

## 使用方法
- `terraform apply` 実行後に出力される IP アドレスに Minecraft 上で接続するとワールドに接続できます。
- 遊ばない場合は AWS コンソール上で EC2 インスタンスを停止してください。
- 再開する場合は AWS コンソール上で EC2 インスタンスを再開してください。ワールドのデータは維持されます。
- EC2 インスタンスに SSH 接続するとコマンドライン上でサーバを操作することが出来ます。コンソール上で接続することも可能です。
- 全てのリソースを削除する場合は `terraform destroy` を実行してください。ワールドのデータも削除されます。
