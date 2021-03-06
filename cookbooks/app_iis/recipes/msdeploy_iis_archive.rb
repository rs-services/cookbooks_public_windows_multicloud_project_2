# Cookbook Name:: app_iis
# Recipe:: msdeploy_from_archive
#
# Copyright 2010, RightScale, Inc.
#
# All rights reserved

# start the default website
powershell "Creates an IIS Web Deploy package of the local web server" do
  parameters({'IIS_PACKAGE' => @node[:app_iis][:iis_package]})
  # Create the powershell script
  powershell_script = <<'POWERSHELL_SCRIPT'
    #tell the script to "stop" or "continue" when a command fails
    $ErrorActionPreference = "stop"
    
    # Add IIS Web Deploy to path
    $msdeployPath="C:\Program Files\IIS\Microsoft Web Deploy"
    $env:path="$env:path;$msdeployPath"


    # Create archive folder
    $IIS_PACKAGE_FOLDER = split-path $env:IIS_PACKAGE
    mkdir -force $IIS_PACKAGE_FOLDER
    cd $IIS_PACKAGE_FOLDER
    
    # Setup MS deploy arguments
    $msdeployArguments = "-verb:sync -source:webServer -dest:package=$env:IIS_PACKAGE "

    # Run web deploy
    Start-Process `
            -FilePath "$msdeployPath\msdeploy.exe" `
            -ArgumentList $msdeployArguments `
            -WorkingDirectory "$IIS_PACKAGE_FOLDER" `
            -RedirectStandardError stderr.txt `
            -RedirectStandardOutput stdout.txt `
            -Wait

    # Display output
    "STDOUT : " + (gc stdout.txt)
    "STDERR : " + (gc stderr.txt)

    gci *.*

    # Clean up files
    if (Test-Path(".\stdout.txt")) { rm .\stdout.txt}
    if (Test-Path(".\stderr.txt")) { rm .\stderr.txt}
    
POWERSHELL_SCRIPT

  source(powershell_script)
end
