# Service Intelligence System

UfficioFacile now includes a local-first Service Intelligence layer for procedure detail pages and generated packs.

## What it adds

- destination guidance for each major procedure
- official-link guidance with verification status
- online and in-person handling notes
- document requirements split into required, recommended, and conditional
- before-sending, follow-up, rejection, and escalation guidance
- clickable explanations for terms such as PEC, SPID, CIE, Voltura, Subentro, and Canone RAI

## Verification rules

- never invent official email, PEC, or office addresses
- mark uncertain information as `needsReview` or `unverified`
- only show a record as `verified` when a clear source exists
- always tell the user to verify the official page before submitting personal data

## City and provider specificity

Many procedures depend on city, region, ASL, Comune, university, or provider. The app should say that clearly instead of pretending that one contact works everywhere.

## Clickable terms

Known procedure terms are rendered as tappable links that open a local explanation page through the `/life-admin/terms` route.
