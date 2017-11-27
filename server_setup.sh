# The following is the transcript of commands used to set up the
# server for the the Texata 2017 finals hackathon.
#
# Austin, November 19, Konstantin Tretyakov
#
# Start with a bare Ubuntu 16.04 VM, with a sudoer ubuntu user.

# -------------- Set-up Python --------------
sudo apt-get update
sudo apt-get install -y unzip imagemagick git
wget https://repo.continuum.io/archive/Anaconda3-5.0.0.1-Linux-x86_64.sh
bash ~/Anaconda3-5.0.0.1-Linux-x86_64.sh -b -p $HOME/anaconda3
echo 'export PATH="$HOME/anaconda3/bin:$PATH"' >> ~/.bashrc
. ~/.bashrc
conda install -y basemap
conda install -y -c conda-forge ffmpeg
conda install -y gensim
pip install --upgrade google-cloud-bigquery pandas-gbq dask ipyparallel tensorflow keras textblob psycopg2 awscli
pip install google-compute-engine # https://stackoverflow.com/a/41622599/318964

# -------------- Set up Jupyter --------------
jupyter notebook --generate-config
echo "c.NotebookApp.ip = '0.0.0.0'" >> ~/.jupyter/jupyter_notebook_config.py

# -------------- Enable ipyparallel --------------
jupyter nbextension install --py ipyparallel --user
jupyter nbextension enable --py ipyparallel --user
jupyter serverextension enable --py ipyparallel --user
# https://stackoverflow.com/a/46737120/318964
cat - <<EOF > ~/.jupyter/jupyter_notebook_config.json
{
  "NotebookApp": {
    "nbserver_extensions": {
      "ipyparallel.nbextension": true
    },
    "server_extensions": [
      "ipyparallel.nbextension"
    ]
  }
}
EOF

# -------------- Launch Jupyter --------------
mkdir work
cd work
screen -S jupy -d -m jupyter notebook

# ---------- Set up PostgreSQL ------------ #
sudo apt install -y postgresql postgresql-client

sudo -u postgres psql <<EOT
  create user ubuntu password 'ubuntu' createdb;
  create database ubuntu owner ubuntu;
  create database texata owner ubuntu;
EOT
echo "listen_addresses = '*'" | sudo tee -a /etc/postgresql/9.5/main/postgresql.conf 
sudo service postgresql restart


# -------------- Configure access to AWS and GC (Requires interactive input) --------------
#gcloud init
#gcloud auth application-default login
#aws configure