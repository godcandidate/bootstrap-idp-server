# Simple End-to-End: Authentik → Cognito OIDC Federation  
This guide describes how to configure Authentik as an OpenID Connect (OIDC) identity provider for AWS Cognito. Once configured, users will be able to authenticate to Cognito applications using Authentik

## Prerequisites

Before proceeding, ensure this requirement is met:

* A **running Authentik instance**, self-hosted or cloud-hosted, accessible via a public HTTPS URL.


## Authentik Setup

1. **Create a Group** (optional but clean)  
   Directory → Groups → Create → Name: `cognito-users`

2. **Create a Test User**  
   Directory → Users → Create  
   - Username: `testuser`  
   - Name: `Test User`  
   - Email: `testuser@example.com`  
   - Password: (set one)  
   - Add to group: `cognito-users`

3. **Create OIDC Provider**  
   Applications → Providers → Create → OAuth2/OpenID Connect Provider  
   - Name: `Cognito OIDC`  
   - Authorization flow: `default-authentication-flow-explicit`  
   - Scopes: `openid email profile`  
   - Signing Key: `Authentik Self-signed Certificate`  
   - Save

4. **Create Application & Link Provider**  
   Applications → Applications → Create  
   - Name: `Cognito Test`  
   - Slug: `cognito-test`  
   - Provider: `Cognito OIDC`  
   - Save

5. **Allow Access – Create & Bind Policy**  
   Policies → Expression Policy → Create  
   - Name: `Allow Cognito Users`  
   - Expression: `return True`  (or `return "cognito-users" in request.user.group_names()` later)  
   → Save  
   Then: Application → `Cognito Test` → Policy bindings → Create → Bind the policy above → Save


## AWS Cognito Setup

1. **Create User Pool** (if you don’t have one)  
   → Standard attributes: require `email`

2. **Add Identity Provider**  
   User Pool → Federation → Identity providers → OpenID Connect  
   - Provider name: `Authentik`  
   - Client ID & Secret: copy from Authentik Provider page  
   - Issuer: `issuer url` (with trailing /)  
   - Scopes: `openid email profile`  
   - Click “Get token endpoint details from issuer” → auto-fills  
   - Attribute mapping (type manually if dropdown empty):  
     `email` → `email`  
   → Save

3. **Enable IdP on App Client**  
   App integration → App clients → Your app client → Edit  
   → Identity providers: check both **Cognito User Pool** and **Authentik** → Save

### Test It
Open in incognito:  
`https://<your-pool-domain>.auth.<region>.amazoncognito.com/login?client_id=<app-client-id>&response_type=code&scope=openid+email+profile&redirect_uri=https://google.com`
