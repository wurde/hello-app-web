# Hello App Web

An example web application.

## Event Log

```bash
# 1. Create an app directory.
mkdir hello-app-web && cd hello-app-web

# 2. Create a React app.
#    http://npmjs.com/package/create-react-app
npx create-react-app . --use-npm

# 3. Configure .gitignore for Terraform.
#    http://npmjs.com/package/gitignore
npx gitignore terraform

# 4. Define Terraform configuration.
echo "# Configure Terraform.

terraform {
  required_version = \"~> 0.13\"

  # https://www.terraform.io/docs/backends/types/s3.html
  backend \"s3\" {
    bucket = \"andys-terraform-backend\"
    region = \"us-east-1\"
    key    = \"hello-app-web/terraform.tfstate\"
  }
}" > terraform.tf

# 5. Add Terraform module "web-app-aws".
echo "# Deploy a client-side application to AWS.

module \"web-app-aws\" {
  source = \"github.com/wurde/web-app-aws\"

  dist_dir      = \"./build\"
  domain        = \"example.com\"
  alias_domains = [\"www.example.com\"]
  default_ttl   = 10
}" > web-app-aws.tf

# 6. Add GitHub Action workflows CI and CD.
mkdir -p .github/workflows

echo "# Continuous Integration via GitHub Actions.

name: Continuous Integration

on:
  push:
    branches-ignore:
      - master

env:
  AWS_ACCESS_KEY_ID: \${{ secrets.AWS_ACCESS_KEY_ID }}
  AWS_SECRET_ACCESS_KEY: \${{ secrets.AWS_SECRET_ACCESS_KEY }}

jobs:
  terraform:
    name: Terraform
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v2

      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v1.1.0
        with:
          terraform_version: '0.13.0-rc1'

      - name: Terraform Format
        run: terraform fmt -check

      - name: Terraform Init
        run: terraform init

      - name: Terraform Validate
        run: terraform validate -no-color

      - name: Terraform Plan
        run: terraform plan -no-color
" > .github/workflows/ci.yaml

echo "# Continuous Delivery via GitHub Actions.

name: Continuous Delivery

on:
  push:
    branches:
      - master

env:
  AWS_ACCESS_KEY_ID: \${{ secrets.AWS_ACCESS_KEY_ID }}
  AWS_SECRET_ACCESS_KEY: \${{ secrets.AWS_SECRET_ACCESS_KEY }}

jobs:
  build:
    name: Build
    runs-on: ubuntu-latest
    steps:
      - name: Checkout Repo
        uses: actions/checkout@v2

      - name: Cache Node Modules
        uses: actions/cache@v2
        with:
          path: node_modules
          key: npm-\${{ hashFiles('**/package-lock.json') }}

      - name: Install Dependencies
        run: npm ci

      - name: Build
        run: npm run build

      - name: Archive Production Artifact
        uses: actions/upload-artifact@v2
        with:
          name: build
          path: build

  terraform:
    name: Terraform
    needs: build
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v2

      - name: Download Artifact
        uses: actions/download-artifact@v2
        with:
          name: build
          path: build

      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v1.1.0
        with:
          terraform_version: '0.13.0-rc1'

      - name: Terraform Format
        run: terraform fmt -check
        continue-on-error: true

      - name: Terraform Init
        run: terraform init

      - name: Terraform Validate
        run: terraform validate -no-color

      - name: Terraform Plan
        run: terraform plan -no-color

      - name: Terraform Apply
        if: github.ref == 'refs/heads/master' && github.event_name == 'push'
        run: terraform apply -auto-approve
" >.github/workflows/cd.yaml

# 7. Save current changes.
git add -A && git commit -m "Setup with Terraform"

# 8. Setup a repository on GitHub and push changes.
#   a) Create a GitHub repository named "hello-app-web".
#   b) Add as the git remote origin.
git remote add origin https://github.com/wurde/hello-app-web.git
#   c) Push changes.
git push -u origin master

# 9. Create an AWS user for GitHub Action CI/CD.
#   a) Create an IAM user.
#   b) Attach the PowerUserAccess policy.
#   c) Create an access key.
#   d) Add the access key credentials as GitHub secrets.
#     - AWS_ACCESS_KEY_ID
#     - AWS_SECRET_ACCESS_KEY

# 10. Run the app in the development mode.
#     Open http://localhost:3000 in browser.
npm start
```

## License

This project is __FREE__ to use, reuse, remix, and resell.
This is made possible by the [MIT license](/LICENSE).
