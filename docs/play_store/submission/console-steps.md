# UfficioFacile — Google Play setup

Updated: 4 November 2026.

## Completed

- Privacy policy published on Vercel and saved in Play Console.
- Reviewer email/password and instructions saved. The dedicated reviewer has Premium access without payment or OTP.
- Ads: **Yes**. Advertising ID: advertising, analytics and fraud prevention.
- IARC content rating: **PEGI 3 / ESRB Everyone**, with in-app purchases.
- Intended audience: **18 and over**.
- Data Safety submitted and accepted through the Play API.
- Government apps: **No**.
- Health: **Healthcare services and management** for SSN/ASL and health-card administration.
- Financial: **Other** for expense/bill tools and educational guidance; **Rewards, points and other incentives** for Premium referral rewards.
- Category: **App → Productivity**.
- Contact: **info@artavasystems.com**, **https://www.artavasystems.com**.
- English and Italian store descriptions, icon, feature graphics and two real Android screenshots per language committed to Google Play.

## Public links

Privacy: https://ufficiofacile-info.vercel.app/privacy

Account or partial data deletion: https://ufficiofacile-info.vercel.app/account-deletion

Official sources and independence statement: https://ufficiofacile-info.vercel.app/sources

Site source: https://github.com/Mohammad-khataeii/UfficioFacile/tree/main/public-site

## Check the saved declarations

1. Open **Play Console → UfficioFacile → Monitor and improve → Policy and programs → App content**.
2. Open **Actioned** to see the saved forms.
3. Open **Grow users → Store presence → Store listings** to see the English and Italian listings.
4. Open **Publishing overview** to see whether changes are saved, in review or published.

All requested setup forms are saved. App content says **You’re all caught up**. Changes are **not yet submitted for review**: Google requires the remaining closed-test steps below first.

## Publish the closed test

1. Open **Test and release → Testing → Closed testing → alpha**.
2. Keep your intended countries and tester list. Add at least 12 willing testers if none are configured.
3. Open the draft release and use build **4**. Follow [the build replacement guide](../update_closed_test.md) if it needs uploading.
4. Resolve any errors shown by Google, review the release, and send it for review.
5. After approval, send testers the opt-in link. They must opt in and remain opted in for at least **14 continuous days**.
6. When Google marks the conditions complete, return to **Dashboard → Apply for production** and answer the questions about the test.

## Keep reviewer access available

Private credentials are stored only on this Mac in `.dart_tool/production-checks/PLAY_REVIEWER_ACCESS.md`. They are also saved in Play Console. Do not add this file to GitHub. Keep the reviewer account active for future reviews.

## Current service limits

Public AI remains disabled until Google Cloud Billing is connected. Native Play Billing product setup is still required before Android purchases can be sold. Do not describe these as completed payment or AI checks.

## Update the privacy website later

Edit `public-site/`, commit only the intended site changes, and push to GitHub. The connected Vercel project **ufficiofacile-info** uses `public-site` as its root directory. Check the public links after deployment.
