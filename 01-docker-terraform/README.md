# Checklist:
1. Created new project on GCP.
2. Installed terraform and added to Windows Environment Variables
3. Installed google-cloud-sdk and added all needed paths to Windows Environment Variables
4. Activated using this command: gcloud auth activate-service-account --key-file %GOOGLE_APPLICATION_CREDENTIALS%
5. tested terraform:
   * terraform plan -var="project=<project-id>"
   * terraform apply -var="project=<project-id>"

![image](https://github.com/yelzha/data-engineering-zoomcamp/assets/54392243/3d2d8b90-da8c-4777-a56c-0cc3aacab752)



# Docker + Postgres
1. Changed docker-compose.yaml and created volume, images in docker
2. Extracted, Loaded data into database using python code
3. Solved all questions in homework.md and wrote awesome sql-query.

That's all for 1st week of learnming.



result of terraform:

D:\ProjectFiles\data-engineering-zoomcamp\01-docker-terraform\1_terraform_gcp\terraform\terraform_test>terraform apply
google_bigquery_dataset.zoomcamp_dataset: Refreshing state... [id=projects/de-zoomcamp-412720/datasets/zoomcamp_dataset]

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # google_bigquery_dataset.zoomcamp_dataset will be created
  + resource "google_bigquery_dataset" "zoomcamp_dataset" {
      + creation_time              = (known after apply)
      + dataset_id                 = "zoomcamp_dataset"
      + default_collation          = (known after apply)
      + delete_contents_on_destroy = false
      + effective_labels           = (known after apply)
      + etag                       = (known after apply)
      + id                         = (known after apply)
      + is_case_insensitive        = (known after apply)
      + last_modified_time         = (known after apply)
      + location                   = "US"
      + max_time_travel_hours      = (known after apply)
      + project                    = "de-zoomcamp-412720"
      + self_link                  = (known after apply)
      + storage_billing_model      = (known after apply)
      + terraform_labels           = (known after apply)
    }

  # google_storage_bucket.de-zoomcamp-bucket-yelzha will be created
  + resource "google_storage_bucket" "de-zoomcamp-bucket-yelzha" {
      + effective_labels            = (known after apply)
      + force_destroy               = true
      + id                          = (known after apply)
      + location                    = "US"
      + name                        = "de-zoomcamp-bucket-yelzha"
      + project                     = (known after apply)
      + public_access_prevention    = (known after apply)
      + rpo                         = (known after apply)
      + self_link                   = (known after apply)
      + storage_class               = "STANDARD"
      + terraform_labels            = (known after apply)
      + uniform_bucket_level_access = (known after apply)
      + url                         = (known after apply)

      + lifecycle_rule {
          + action {
              + type = "AbortIncompleteMultipartUpload"
            }
          + condition {
              + age                   = 1
              + matches_prefix        = []
              + matches_storage_class = []
              + matches_suffix        = []
              + with_state            = (known after apply)
            }
        }
    }

Plan: 2 to add, 0 to change, 0 to destroy.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

google_bigquery_dataset.zoomcamp_dataset: Creating...
google_storage_bucket.de-zoomcamp-bucket-yelzha: Creating...
google_bigquery_dataset.zoomcamp_dataset: Creation complete after 1s [id=projects/de-zoomcamp-412720/datasets/zoomcamp_dataset]
google_storage_bucket.de-zoomcamp-bucket-yelzha: Creation complete after 2s [id=de-zoomcamp-bucket-yelzha]

Apply complete! Resources: 2 added, 0 changed, 0 destroyed.

D:\ProjectFiles\data-engineering-zoomcamp\01-docker-terraform\1_terraform_gcp\terraform\terraform_test>
