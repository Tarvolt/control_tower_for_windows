# Use Python 3.8 image from Docker Hub
FROM mcr.microsoft.com/windows/servercore:ltsc2019

# Install Chocolatey packages manager
RUN @powershell -NoProfile -ExecutionPolicy unrestricted -Command "$env:chocolateyUseWindowsCompression = 'false'; (iex ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1'))) >$null 2>&1"

# Install Python 3.8.0
RUN choco install -y python --version 3.8.0

# Install pip
RUN curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
RUN python get-pip.py

# Install packages
RUN pip install --upgrade pip
RUN pip install --upgrade setuptools
RUN pip install --upgrade 'requests==2.31.0'
RUN pip install --upgrade 'cryptography==3.4.7'
RUN pip install dulwich paramiko boto3
RUN pip install git+https://github.com/carrier-io/arbiter.git
RUN pip install git+https://github.com/carrier-io/loki_logger.git

COPY . /app
WORKDIR /app

# Install application
RUN mkdir \reports && python setup.py install && rm -rf control_tower requirements.txt setup.py

ENV PYTHONUNBUFFERED=1
ADD run.bat /bin/run.bat
RUN chmod +x /bin/run.bat

COPY config.yaml /

SHELL ["cmd", "/C", "\"C:/Program Files/Git/git-cmd.exe\"", "-c"]

ENTRYPOINT ["run.bat"]