# Bootstrap

This folder contains the bootstrap config required for state management using s3 and dynamodb.

It also manages the `/service_accounts/github_api_token` and `/service_accounts/github_api_user` secrets, and the `alias/github-credentials` key that encrypts them. The vault policy generator in platsec-production reads both secrets across accounts. The token value is set by the credentials rotation script in [platsec-utils](https://github.com/hmrc/platsec-utils/tree/main/credentials-rotation).

## Plan

```bash
make plan-bootstrap
```

## Apply

```bash
make apply-bootstrap
```
