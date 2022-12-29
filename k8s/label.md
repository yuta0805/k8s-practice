# kubernetesのlabel, annotaitionsについて
## annotationとは
- metadata項目で定義することができるリソースのメモ書きのようなもの
- ただのkey-value値であり、アノテーションを元に何らかのシステム的な処理をしない場合はただの値でしかない

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: sample-app
  annotaitons:
    hoge: fuga
    //数値を扱う場合はダブルクオートしないといけない。
    hoge: "100"
spec:
```

### annotationの活用法は主に3つ
1, システムコンポーネントのためにデータを保存する
2, 全ての環境では利用できない設定をおこう
3, 正式に組み込まれる前の機能の設定

### システムコンポーネントのためにデータを保存する
- リソース更新時に参照するannotationとして```kubeclt.kubernetes.io/last-applied-configuration```があり、これはkubernetesのエコシステムで付与されるannotationである。これをもとにkubernetesではリソース更新(古いリソースとして認識する)する

```yaml
apiVersion: apps/v1
kind: ReplicaSet
metadata:
  annotations:
    kubectl.kubernetes.io/last-applied-configuration: | //自動的に付与されている
      {"apiVersion":"apps/v1","kind":"ReplicaSet","metadata":{"annotations":{},"name":"sample-replica-set","namespace":"default"},"spec":{"replicas":1,"selector":{"matchLabels":{"app":"sample-pod"}},"template":{"metadata":{"labels":{"app":"sample-pod"}},"spec":{"containers":[{"image":"nginx:1.16","name":"nginx"}]}}}}
```

- datadogなどのagentのpod識別として活方される
  - datadogはagentをdeansetとしてデプロイされ、podのログを収集している。podを識別する為にpodのannotationにdatadog由来のannotationを追加する。valueとして特定に必要なtag名を埋め込む
```yaml
annotations:
  ad.datadoghq.com/tags: '{"<タグキー>": "<タグ値>","<タグキー_1>": "<タグ値_1>"}'
```
[tagのオートディスカバリ](https://docs.datadoghq.com/ja/containers/kubernetes/tag/?tab=containerizedagent#:~:text=Agent%20v6.10%20%E4%BB%A5%E9%99%8D%E3%81%A7%E3%81%AF%E3%80%81Agent%20%E3%81%AF%E3%83%9D%E3%83%83,%E3%82%AB%E3%82%B9%E3%82%BF%E3%83%A0%E3%82%BF%E3%82%B0%E3%82%92%E9%96%A2%E9%80%A3%E4%BB%98%E3%81%91%E3%82%8B%E3%81%93%E3%81%A8%E3%81%8C%E3%81%A7%E3%81%8D%E3%81%BE%E3%81%99%E3%80%82)より

### 全ての環境では利用できない設定を行う
- kubernetesを利用する環境はcloud providerにとって様々。各環境特有の機能があったりするので、annotationsを私用することで特有の設定を表現する
```yaml
// eksでのservice type load balancerのannotationによる設定例
apiVersion: v1
kind: Service
metadata:
  name: aws-nlb
  annotations:
    service.beta.kubernetes.io/aws-load-balancer-type: external
    service.beta.kubernetes.io/aws-load-balancer-nlb-target-type: instance
    service.beta.kubernetes.io/aws-load-balancer-scheme: internet-facing
    service.beta.kubernetes.io/aws-load-balancer-name: vamdemic-nlb
    external-dns.alpha.kubernetes.io/hostname: nginx.vamdemicsystem.com
```

### 正式に組み込まれる前の機能設定を行う
- kubernetesに正式に組み込まれる前の実験的な機能や評価中の新機能設定をアノテーションを使って行う場合

## labelとは
- ```metadata.labels```に設定できるメタデータ。**リソースを分別するするための情報**
- replicasetではpodに付与されたlabeをもとに識別しpodの数を数えることでレプリカ数を管理している
```yaml
// replicasetのspec.selector.matchLabels[].参照するラベル名で指定して、ラベルのvalueに一致しているものを監視
apiVersion: apps/v1
kind: ReplicaSet
metadata:
  name: sample-replica-set

spec:
  replicas: 1
  selector:
    matchLabels: //podのlabelを監視監視する app = sample-podに相当するlabelが付与されているpodを管理かにおく
      app: sample-pod
  
  template: //podの設定
    metadata:
      labels:
        app: sample-pod //podのラベル
    spec:
      containers:
        - name: nginx
          image: nginx:1.16

```
