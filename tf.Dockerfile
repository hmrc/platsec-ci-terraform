ARG TF_BASE_TAG
FROM hashicorp/terraform:${TF_BASE_TAG}

# Opt out of git's safe.directory check to allow download of source modules from git repos.
# A workaround for 
# │ /usr/bin/git exited with 128: fatal: detected dubious ownership in
# │ repository at
RUN echo -e "[safe]\n\tdirectory = *" > /etc/gitconfig
