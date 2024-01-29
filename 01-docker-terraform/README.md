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
