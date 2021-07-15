# Bootstrap

This folder contains the bootstrap terraform required for s3/dynamo state management.
In order to allow changes, the state of the bootstrap is managed with the following steps

## For first time run

- comment out the `backend "s3" {}` block in the [main.tf](./main.tf) file
- run `terraform init` and `terraform apply`
- uncomment the `backend "s3" {}` block
- now you can run `terraform init -backend-config=backend.hcl` to move the state to the bucket you just created
- done ✅

## For successive runs

- run:

    ```bash
    AWS_PAGER="" aws secretsmanager get-secret-value \
      --secret-id "backend.hcl" \
      --query="SecretString" \
      --output=text \
      > backend.hcl
    ```

- then run: `terraform init -backend-config=backend.hcl`
- you are now free to make changes e.g. `terraform apply`
- done ✅
