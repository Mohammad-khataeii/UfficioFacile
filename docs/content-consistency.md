# Content Consistency

Use the content doctor after every export:

```bash
dart run tool/content_doctor.dart
```

The content doctor verifies:

- bundled export exists in both output locations
- canonical `categories` tree exists
- all 11 required categories exist
- `cmsCategories`, `cmsProcedures`, and `cmsContentBlocks` are present
- docs/admin export counts match
- required premium money categories are premium-gated
- localized category and procedure titles exist for `en`, `it`, `fr`, `es`, `fa`, `ar`
- duplicate category slugs are not present

Use admin content lint for broader public-copy and structure checks:

```bash
cd apps/admin
npm run content:lint
```
