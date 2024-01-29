variable "credentials" {
  description = "My Credentials"
  default     = "C:/Users/yelzha/AppData/Roaming/gcloud/de-zoomcamp-412720-a3b1e76e7cf1.json"
}

variable "project" {
  type = string
  default = "de-zoomcamp-412720"
}

variable "region" {
  type = string
  default = "us-central1"
}

variable "gcs_bucket_name" {
  type = string
  default = "de-zoomcamp-bucket-yelzha"
}

variable "location" {
  type = string
  default = "US"
}

variable "bq_dataset_name" {
  type = string
  default = "zoomcamp_dataset"
}