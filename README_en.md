# Omero-Web - building a ready-to-use Docker container for OMERO in auto-login mode


OMERO (<http://www.openmicroscopy.org>) is a software platform for visualization, management and analysis of biological microscope images. It is being developed by the OME consortium of various partners led by Prof Jason Swedlow of the University of Dundee. 


## Prerequisite

* Please install Docker (<https://docs.docker.com/engine/getstarted/step_one/>).
If you are using Mac OS Yosemite 10.10.3 or later, "Docker for Mac" is recommended over Docker Toolbox. However, Docker for Mac only works on Mac with hardware virtualization that may not be supported by some Mac hardware. Please refer to Docker site for more details.

* Please install Git (https://git-scm.com/book/en/v2/Getting-Started-Installing-Git) and clone omero-web
	```
       # git clone https://github.com/openssbd/omero-web.git
       ```
* Alternatively, you can download the zip file (https://github.com/openssbd/omero-web/archive/master.zip) instead of using Git and rename the directory as omero-web.

## Installing OMERO.server as a container and start up

  1. Use a terminal or co and line, enter the omero-web directory and run "sh run.sh". It will install automatically create a Docker image and install OMERO.server. The OMERO.server will start up in a new Docker containe. The installation requires downloading OMERO.server from the Internet and it may take close to an hour in some circumstances.
  
    ```
    # cd ~/omero-web/
    # ls
    Dockerfile   OMERO.insight1.png   ... run.sh  ...   setup/
    (Please confirm that run.sh is in your directory?
    # sh run.sh
    ```
    
    Successfully built (this message will be displayed to inform you that the omero-web image has been built successfully)
    OMERO.server (starting up omero will display in 20s or so)
    
    ```
    Step 41/41 : CMD /bin/bash /start.sh && tail -f /dev/null
     ---> Using cache
     ---> 1cc743c65045
    Successfully built 1cc743c65045
    omero-web
    omero-web
    a54fe17253be899e79b8ec93d39ec0f5062e85844cc82fc7cb01474266d975c7
    ```
    
  2. Connecting to omero-web (OMERO.server inside a Docker container) with a browser by entering the following URL
  
    * <http://localhost/image/>
    
    ![Alt text](OMERO.web.png?raw=true "OMERO.server image")
    

## Adding new images into omero-web

Using OMERO.insight to connect to the omero-web Docker container

1. Please download OMERO.insight here <http://downloads.openmicroscopy.org/omero/5.2.7/> 
a. Choose the right version for your OS platform. For example, if you are using Mac OSX, choose OMERO.insight-5.2.7-ice35-b40-mac.zip.
    
  2. After you unzip the application, please click on OMERO.insight.app to start OMERO.insight
  
  3. When connecting to omero-web (OMERO.server in Docker)
    * Please enter the following user name and password
    * Username: public_data
    * Password: public_data

    ![Alt text](OMERO.insight1.png?raw=true "OMERO.insight" image)
    
  4. For more information on importing data, please refer to the OMERO documentation here

http://help.openmicroscopy.org/importing-data-5.html 

## Additional Note:

* If you are planning to use this script to create a public facing OMERO.server, please check the security of the container and change the passwords for root and other accounts.

    <table class="wiki">
    <tr><th><strong>Account type </strong></th><th><strong>Username</strong></th><th><strong>Password</strong></th></tr>
    <tr><td>System Administration Account</td><td>root</td><td>root</td></tr>
    <tr><td>System Database Account</td><td>postgres</td><td>postgres</td></tr>
    <tr><td>System OMEROAccount</td><td>omero</td><td>omero</td></tr>
    <tr><td>Database Admin account</td><td>postgres</td><td>postgres</td></tr>
    <tr><td>Database OMERO Account</td><td>db_user</td><td>db_password</td></tr>
    <tr><td>OMERO Admin account</td><td>root</td><td>root_password</td></tr>
    <tr><td>OMERO User Account</td><td>public_data</td><td>public_data</td></tr>
    </table>


