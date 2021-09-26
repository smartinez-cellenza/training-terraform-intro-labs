# Setup environment

## Lab overview

In order to deploy infrastructure with Terraform some configuration is mandatory, without considering the resources themselfs. This configuration is about:

- **Authentication**: Terraform needs to handle authentication to the Azure Cloud API.

- **Backend**: Terraform use a backend file, called tfstate. This file is used to map real world resources to the configuration template. It is mandatory for Terraform.

- **Providers**: Providers are plugins used to interact with Cloud Providers APIs.

In this lab, you will learn how to setup this three aspects in a new Terraform template.

## Objectives

After you complete this lab, you will be able to:

-   Setup a new Terraform project

## Instructions

### Before you start

- Ensure Terraform (version >= 1.0.0) is installed and available from system's PATH.
- Ensure Azure CLI is installed.
- Check your access to the Azure Subscription and Resource Group provided for this training.

### Exercise 1: Create a Storage Account and a Container

In order to store the Terraform tfstate file, we're going to use a Blob Storage.

By default, Terraform will create this file locally, in a file nammed *terraform.tfstate*. This file contains informations on real world infrastructure, including sensible data (for instance, Virutal Machines admin account password). There are reasons why this option should be disregared

- Templates should be commited to a source code repository, and should not contains sensible data.
- A deployment should be required when the author of the template is on vacation, collaborative work should be the norm.
- Using a file in a network share won't protect from collision if there are multiple deployments at the same time

An alternative is to use an Azure Blob storage to store the tfstate :

- tfstate won't be commited in source code.
- Access to the tfstate is managed using RBAC or SAS (Shared Access Signature) token.
- Blob Storage has a lock feature nativelly used by Terraform, protecting from collision in case on multiple deployment at the same time

Create a Storage Account and a container in the Azure Portal

> Terraform will not create this storage and assume it is existing. This should be the unique manual creation when you use Terraform.

> The creation of this storage should be done using AZ CLI or Powershell


### Exercice 2: Setup the template configuration

#### Create the configuration file

1. In a local empty folder, create a file nammed *main.tf*

    > The name of the file has no importance, only its extension. main.tf is only a convention

1. In this file, add the following configuration block

    ```hcl
    terraform {
      required_version = ">= 1.0.0"
    }
    ```

    The *required_version* setting allows to set a version constraint on the installed Terraform version.

1. In the terraform configuration block add the backend configuration using information on the Storage Account you created previously:

    ```hcl
    backend "azurerm" {
      resource_group_name  = "[name of the Resource Group of the Storage Account]"
      storage_account_name = "[name of the Storage Account]"
      container_name       = "[Name of the container]"
      key                  = "training.tfstate"
    }
    ```

    > There are multiple type of backend that might be used. All majors Cloud Providers have their own (s3 for AWS, gcs for GCP,... )

    > This configuration is valid for an authentication using AZ CLI. If you're using a Service Principal or a Managed Identity, additionnal fields may be mandatory. https://www.terraform.io/docs/language/settings/backends/azurerm.html

1. In the terraform configuration block add the provider requirements:

    ```hcl
    required_providers {
      azurerm = ">= 2.75.0"
    }
    ```

    We can set here a version constraint on the provider

1. Add a provider block for the azurerm provider

    ```hcl
    provider "azurerm" {
      skip_provider_registration = true
      features {}
      subscription_id = [Id of the provided subscription]
    }
    ```

    The configuration of the azurerm provider:
    - **skip_provider_registration**: The provider will not try to register all the Resource Providers it supports
    - **feature**: List of features that might be activated on the provider
    - **subscription_id**: The Id of the subscription

    > All the available settings can be found here - https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs

The full content of the file should be

```hcl
terraform {
  required_version = ">= 1.0.0"

  backend "azurerm" {
    resource_group_name  = "[name of the Resource Group of the Storage Account]"
    storage_account_name = "[name of the Storage Account]"
    container_name       = "[Name of the container]"
    key                  = "training.tfstate"
  }

  required_providers {
    azurerm = ">= 2.75.0"
  }
}

provider "azurerm" {
  skip_provider_registration = true
  features {}
  subscription_id = "[Id of the provided subscription]"
}
```

> Do not waste time trying to format the template nicelly. Use the 'terraform fmt -recursive' command instead. https://www.terraform.io/docs/cli/commands/fmt.html

#### Terraform init

Once your template is ready, open a new shell and login using AZ CLI

```bash
az login
```

Select the provided training subscription
```
az account set --subscription [subscriptionId]
```

The first terraform command to run once you created your template is

```hcl
terraform init
```

This command has no side effects (ie: It will not modify any resources nor update the tfstate file). It can be run at anytime.

It will
- Intialize the backend
- Download providers

![terraform_init](assets/terraform_init.PNG)


1.  On your lab computer, start a web browser and navigate to [Azure DevOps Demo Generator](https://azuredevopsdemogenerator.azurewebsites.net). This utility site will automate the process of creating a new Azure DevOps project within your account that is prepopulated with content (work items, repos, etc.) required for the lab.

    > **Note**: For more information on the site, see https://docs.microsoft.com/en-us/azure/devops/demo-gen.

1.  Click **Sign in** and sign in using the Microsoft account associated with your Azure DevOps subscription.
1.  If required, on the **Azure DevOps Demo Generator** page, click **Accept** to accept the permission requests for accessing your Azure DevOps subscription.
1.  On the **Create New Project** page, in the **New Project Name** textbox, type **Version Controlling with Git in Azure Repos**, in the **Select organization** dropdown list, select your Azure DevOps organization, and then click **Choose template**.
1.  In the list of templates, locate the **PartsUnlimited** template and click **Select Template**.
1.  Back on the **Create New Project** page, click **Create Project**

    > **Note**: Wait for the process to complete. This should take about 2 minutes. In case the process fails, navigate to your DevOps organization, delete the project, and try again.

1.  On the **Create New Project** page, click **Navigate to project**.

#### Task 2: Install and configure Git and Visual Studio Code

In this task, you will install and configure Git and Visual Studio Code, including configuring the Git credential helper to securely store the Git credentials used to communicate with Azure DevOps. If you have already implemented these prerequisites, you can proceed directly to the next task.

1.  If you don't have Git 2.29.2 or later installed yet, start a web browser, navigate to the [Git for Windows download page](https://gitforwindows.org/) download it, and install it.
1.  If you don't have Visual Studio Code installed yet, from the web browser window, navigate to the [Visual Studio Code download page](https://code.visualstudio.com/), download it, and install it.
1.  If you don't have Visual Studio C# extension installed yet, in the web browser window, navigate to the [C# extension installation page](https://marketplace.visualstudio.com/items?itemName=ms-dotnettools.csharp) and install it.
1.  On the lab computer, open **Visual Studio Code**.
1.  In the Visual Studio Code interface, from the main menu, select **Terminal \| New Terminal** to open the **TERMINAL** pane.
1.  Make sure that the current Terminal is running **PowerShell** by checking if the drop-down list at the top right corner of the **TERMINAL** pane shows **1: powershell**

    > **Note**: To change the current Terminal shell to **PowerShell** click the drop-down list at the top right corner of the **TERMINAL** pane and click **Select Default Shell**. At the top of the Visual Studio Code window select your preferred terminal shell **Windows PowerShell** and click the plus sign on the right-hand side of the drop-down list to open a new terminal with the selected default shell.

1.  In the **TERMINAL** pane, run the following command below to configure the credential helper.

    ```git
    git config --global credential.helper wincred
    ```
1.  In the **TERMINAL** pane, run the following commands to configure a user name and email for Git commits (replace the placeholders in braces with your preferred user name and email):

    ```git
    git config --global user.name "<John Doe>"
    git config --global user.email <johndoe@example.com>
    ```

### Exercise 1: Clone an existing repository

In this exercise, you use Visual Studio Code to clone the Git repository you provisioned as part of the previous exercise.

#### Task 1: Clone an existing repository

In this task, you will step through the process of cloning a Git repository by using Visual Studio Code.

1.  If needed, start a web browser, navigate to your Azure DevOps organization, and open the **Version Controlling with Git in Azure Repos** project you generated in the previous exercise.

    > **Note**: Alternatively, you can access the project page directly by navigating to the [https://dev.azure.com/`<your-Azure-DevOps-account-name>`/Version%20Controlling%20with%20Git%20in%20Azure%20Repos](https://dev.azure.com/`<your-Azure-DevOps-account-name>`/Version%20Controlling%20with%20Git%20in%20Azure%20Repos) URL, where the `<your-Azure-DevOps-account-name>` placeholder, represents your account name.

1.  In the vertical navigational pane of the of the DevOps interface, select the **Repos** icon.
1.  In the upper right corner of the **PartsUnlimited** pane, click **Clone**.

    > **Note**: Getting a local copy of a Git repo is called *cloning*. Every mainstream development tool supports this and will be able to connect to Azure Repos to pull down the latest source to work with. Navigate to the **Repos** hub.

1.  On the **Clone Repository** panel, with the **HTTPS** Command line option selected, click the **Copy to clipboard** button next to the repo clone URL.

    > **Note**: You can use this URL with any Git-compatible tool to get a copy of the codebase.

1.  Close the **Clone Repository** panel.
1.  Switch to **Visual Studio Code** running on your lab computer.
1.  Click the **View** menu header and, in the drop-down menu, click **Command Palette**.

    > **Note**: The Command Palette provides an easy and convenient way to access a wide variety of tasks, including those implemented as 3rd party extensions. You can use the keyboard shortcut **Ctrl+Shift+P** to open it.

1.  At the Command Palette prompt, run the **Git: Clone** command.

    > **Note**: To see all relevant commands, you can start by typing **Git**.

1.  In the **Provide repository URL or pick a repository source** text box, paste the repo clone URL you copied earlier in this task and press the **Enter** key.
1.  Within the **Select Folder** dialog box, navigate to the C: drive, create a new folder named **Git**, select it, and then click **Select Repository Location**.
1.  When prompted, log in to your Azure DevOps account.
1.  After the cloning process completes, once prompted ,in the Visual Studio Code, click **Open** to open the cloned repository.

    > **Note**: You can ignore warnings you might receive regarding problems with loading of the project. The solution may not be in the state suitable for a build, but we're going to focus on working with Git, so building the project is not required.

### Exercise 2: Manage branches from Azure DevOps

In this exercise, you will work with branches by using Azure DevOps. You can manage your repo branches directly from the Azure DevOps portal, in addition to the functionality available in Visual Studio Code.

#### Task 1: Create a new branch

In this task, you will create a branch by using the Azure DevOps portal and use fetch it by using Visual Studio Code.

1.  Switch to the the web browser displaying your Azure DevOps organization with the **Version Controlling with Git in Azure Repos** project you generated in the previous exercise.

    > **Note**: Alternatively, you can access the project page directly by navigating to the [https://dev.azure.com/`<your-Azure-DevOps-account-name>`/Version%20Controlling%20with%20Git%20in%20Azure%20Repos) URL, where the `<your-Azure-DevOps-account-name>` placeholder, represents your account name.

1.  In the web browser window, navigate to the **Commits** pane of the project and select **Branches**.
1.  On the **Branches** pane, click **New branch**.
1.  In the **Create a branch** panel, in the **Name** textbox, type **release**, ensure that **master** appears in the **Based on** dropdown list, in the **Work items to link** drop-down list, select one or more available work items, and click **Create**.
1.  Switch to the **Visual Studio Code** window.
1.  Press **Ctrl+Shift+P** to open the **Command Palette**.
1.  At the **Command Palette** prompt, start typing **Git: Fetch** and select **Git: Fetch** when it becomes visible. This command will update the origin branches in the local snapshot.
1.  In the lower left corner of the Visual Studio Code window, click the **master** entry again.
1.  In the list of branches, select **origin/release**. This will create a new local branch called **release** and check it out.

#### Task 2: Delete and restore a branch

In this task, you will use the Azure DevOps portal to delete and restore the branch you created in the previous task.

1.  Switch to the web browser displaying the **Mine** tab of the **Branches** pane in the Azure DevOps portal.
1.  On the **Mine** tab of the **Branches** pane, hover the mouse pointer over the **release** branch entry to reveal the ellipsis symbol on the right side.
1.  Click the ellipsis, in the pop-up menu, select **Delete branch**, and, when prompted for confirmation, click **Delete**.
1.  On the **Mine** tab of the **Branches** pane, select the **All** tab.
1.  On the **All** tab of the **Branches** pane, in the **Search branch name** text box, type **release**.
1.  Review the **Deleted branches** section containing the entry representing the newly deleted branch.
1.  In the **Deleted branches** section, hover the mouse pointer over the **release** branch entry to reveal the ellipsis symbol on the right side.
1.  Click the ellipsis, in the pop-up menu and select **Restore**.

    > **Note**: You can use this functionality to restore a deleted branch as long as you know its exact name.

#### Task 3: Lock and unlock a branch

In this task, you will use the Azure DevOps portal to lock and unlock the master branch.

Locking is ideal for preventing new changes that might conflict with an important merge or to place a branch into a read-only state. Alternatively, you can use branch policies and pull requests instead of locking if you just want to ensure that changes in a branch are reviewed before they are merged.

Locking does not prevent cloning of a repo or fetching updates made in the branch into your local repo. If you lock a branch, share with your team the reason for locking it and make sure they know what to do to work with the branch after it is unlocked.

1.  Switch to the web browser displaying the **Mine** tab of the **Branches** pane in the Azure DevOps portal.
1.  On the **Mine** tab of the **Branches** pane, hover the mouse pointer over the **master** branch entry to reveal the ellipsis symbol on the right side.
1.  Click the ellipsis and, in the pop-up menu, select **Lock**.
1.  On the **Mine** tab of the **Branches** pane, hover the mouse pointer over the **master** branch entry to reveal the ellipsis symbol on the right side.
1.  Click the ellipsis and, in the pop-up menu, select **Unlock**.

#### Task 4: Tag a release

In this task, you will use the Azure DevOps portal to tag a release in the Azure DevOps Repos.

The product team has decided that the current version of the site should be released as v1.1.0-beta.

1.  In the vertical navigational pane of the of the Azure DevOps portal, in the **Repos** section, select **Tags**.
1.  In the **Tags** pane, click **New tag**.
1.  In the **Create a tag** panel, in the **Name** text box, type **v1.1.0-beta**, in the **Based on** drop-down list leave the **master** entry selected, in the **Description** text box, type **Beta release v1.1.0** and click **Create**.

    > **Note**: You have now tagged the project at this release. You could tag commits for a variety of reasons and Azure DevOps offers the flexibility to edit and delete them, as well as manage their permissions.

### Exercise 3: Manage repositories

In this exercise, you will use the Azure DevOps portal to create and delete a Git repository in Azure DevOps Repos.

You can create Git repos in team projects to manage your project's source code. Each Git repo has its own set of permissions and branches to isolate itself from other work in your project.

#### Task 1: Create a new repo from Azure DevOps

In this task, you will use the Azure DevOps portal to create a Git repository in Azure DevOps Repos.

1.  In the web browser displaying the Azure DevOps portal, in the vertical navigational pane, click the plus sign in the upper left corner, directly to the right of the project name and, in the cascading menu, click **New repository**.
1.  In the **Create a repository** pane, in the **Repository type**, leave the default **Git** entry, in the **Repository name** text box, type **New Repo**, leave other settings with their default values, and click **Create**.

    > **Note**: You have the option to create a file named **README.md**. This would be the default markdown file that is rendered when someone navigates to the repo root with a web browser. Additionally, you can preconfigure the repo with a **.gitignore** file. This file specifies which files, based on naming pattern and/or path, to ignore from source control. There are multiple templates available that include the common patterns and paths to ignore based on the project type you are creating.

    > **Note**: At this point, your repo is available. You can now clone it with Visual Studio Code or any other git-compatible tool.

#### Task 2: Delete and rename Git repos

In this task, you will use the Azure DevOps portal to delete a Git repository in Azure DevOps Repos.

Sometimes you'll have a need to rename or delete a repo, which is just as easy.

1.  In the web browser displaying the Azure DevOps portal, at the bottom of the vertical navigational pane, click **Project settings**.
1.  In the **Project Settings** vertical navigational pane, scroll down to the **Repos** section and click **Repositories**.
1.  On the **Repositories** tab of the **All Repositories** pane, hover the mouse pointer over the **New Repo** branch entry to reveal the ellipsis symbol on the right side.
1.  Click the ellipsis, in the pop-up menu, select **Delete**, in the **Delete New Repo repository** panel, type **New Repo**, and click **Delete**.

#### Review

In this lab, you used the Azure DevOps portal to manage branches and repositories.