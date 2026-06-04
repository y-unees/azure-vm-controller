# Azure VM Controller 📱☁️

A lightweight, open-source mobile application built with Flutter to seamlessly manage Microsoft Azure Virtual Machines. Perfect for students and developers utilizing free tiers (like the Azure Free Student Pack) who need to quickly start or stop (deallocate) their cloud servers on the go to preserve credits without losing static configurations.

## Features ✨

- **Multi-Server Dashboard:** Add and manage multiple servers (your own and shared client/friend servers) side-by-side.
- **Real-Time Status Monitoring:** Instantly view whether your VM is actively `Running`, `Deallocated`, or fetching data.
- **One-Tap Power Control:** Securely wake up or shut down instances directly through the official Azure Resource Manager (ARM) REST APIs.
- **Cost Preservation:** Enforces `Deallocate` mode on stop actions, guaranteeing that Azure completely halts hardware allocation fees.
- **Secure Local Storage:** Device credentials and keys are isolated locally on your smartphone via secure local preferences.

---

## How It Works 🛠️

The application securely communicates with the Azure Cloud platform utilizing OAuth 2.0 Client Credentials authentication via Microsoft Entra ID (formerly Azure Active Directory).

```
[ Flutter App ] --------( OAuth 2.0 Handshake )--------> [ Microsoft Entra ID ]
|                                                          |
(Bearer Token)                                             (Access Token)
|                                                          v
+--------------> [ Azure Resource Manager ] -------------> [ Your VM Instance ]
```

---

## Azure Pre-Requisites & Setup 🔐

To protect your virtual machines, Azure requires explicit API access configurations. Follow these steps to obtain your connection keys:

### 1. Configure a Static Public IP (Recommended)
By default, stopping a VM dynamically reassigns its public IP address. To prevent losing your connection details:
1. Navigate to your Virtual Machine in the **Azure Portal**.
2. Click **Networking** -> Select your **Network Interface (NIC)**.
3. Choose **IP configurations**, click your primary configuration (`ipconfig1`), and toggle Assignment from **Dynamic** to **Static**. Save the changes.

### 2. Register Your Controller App in Azure
1. Go to **Microsoft Entra ID** inside your Azure portal portal.
2. Select **App registrations** from the sidebar -> Click **+ New registration**.
3. Name it (e.g., `Azure-VM-Controller`) and click **Register**.
4. **Copy and Save:** Note down the **Application (client) ID** and **Directory (tenant) ID** from the overview page.

### 3. Generate a Client Secret Key
1. Inside your new App Registration, click **Certificates & secrets** in the left menu.
2. Choose **Client secrets** -> **+ New client secret**. Provide a brief description and expiration time.
3. **CRITICAL:** Immediately copy the string inside the **Value** column. *Note: Azure hides this permanently once you leave the webpage.*

### 4. Grant Virtual Machine Access Permissions
1. Go to your target **Virtual Machine** dashboard.
2. Select **Access control (IAM)** from the left menu -> Click **+ Add** -> **Add role assignment**.
3. Search for and select the **Virtual Machine Contributor** role. Click Next.
4. Set "Assign access to" to **User, group, or service principal**, and click **+ Select members**.
5. Search for your App Registration name (`Azure-VM-Controller`), select it, and click **Review + assign**.

---

## Getting Started with Flutter 🚀

### Dependencies
This project utilizes the following Core Flutter plugins:
- `http` - For structured REST API operations with ARM endpoints.
- `shared_preferences` - Local engine caching saved machine environments locally.

### Installation & Run
1. **Clone the repository:**
   ```bash
   git clone [https://github.com/YOUR_GITHUB_USERNAME/azure-vm-controller.git](https://github.com/y-unees/azure-vm-controller.git)
   cd azure-vm-controller
   ```

2. Fetch packages
    ```bash
    flutter pub get
    ```

3. Compile and execute application
    ```bash
    flutter run
    ```

### Security Best Practices
When using or contributing to this project, please keep security top of mind.
- *Never Hardcode secrets*: The application relies on dynamically populated text entries saved locally on your hardware storage. Never hardcode Client Secrets directly into the source Dart classes.

- *Gitignore safety*: If you modify configurations or generate tests with mocked properties, verify that variables containing tracking codes or API keys are excluded from tracking updates via `.gitignore`.

### License 
This project is licensed under the MIT License. Contributions, bug reports, and features implementations are fully welcome!