# Deploy the privacy policy site with AWS Amplify

The static site is in `privacy-policy-site/`. The repository-root `amplify.yml` tells Amplify to publish that directory without a frontend framework build.

## Before deploying

1. Confirm the support email in `privacy-policy-site/index.html` is correct and monitored.
2. Review the policy against the app's final behavior, your AdMob/Google consent configuration, and the disclosures you will enter in Play Console (especially Data Safety). This is a project-specific starting draft, not legal advice.
3. Commit and push the website and root `amplify.yml` to your Git provider.

## Amplify Hosting

1. In AWS Console, open **AWS Amplify → Hosting → Create new app → Host web app**.
2. Connect the Git repository and select the branch to publish.
3. Keep the repository root as the app root and use the committed `amplify.yml` build specification.
4. Save and deploy. Amplify will publish `privacy-policy-site/` and provide an HTTPS URL.
5. Open the URL, verify the policy and contact link, then use that public HTTPS URL in the app's Google Play Console privacy-policy field. A custom domain is optional.

The site is static and does not need environment variables, a backend, or a JavaScript framework.
