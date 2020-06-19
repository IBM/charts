# Release Notes

Latest release: `v1.1.2`

## What's new...

v1.1.2 
  * Added language support for:
    * Bengali
    * Gujarati
    * Malayalam
    * Maltese
    * Nepali
    * Sinhala
    * Tamil
    * Telugu

v1.1.1 
  * Added language support for:
    * Latvian
    * Urdu
    * Vietnamese

v1.0.0 
  * Initial release

## Fixes

v1.1.2
  * Latest security patches in all images 
  * Parameter `global.image.repository` changed to `global.dockerRegistryPrefix` 
  * Parameter `persistence.storageClass`  changed to  `global.storageClassName` 
  * Included `license` parameter, which need to be set as `true` to install

## Prerequisites

See [README.md](./README.md)

## Breaking Changes

None

## Documentation

See [README.md](./README.md)

## Version History

| Chart | Date              | Kubernetes Version Required | Breaking Changes | Details |
| ----- | ----------------- | --------------------------- | ---------------- | ------- |
| 1.1.0 | November 30th, 2019 | >=1.11 | None | Initial Release |
| 1.1.1 | February 28th, 2020 | >=1.11 | None | Added language support for Latvian, Urdu, Vietnamese; latest security patches |
| 1.1.2 | June 9th, 2020 | >=1.11 | None | Added language support for Bengali, Gujarati, Malayalam, Maltese, Nepali, Sinhala, Tamil, Telugu; latest security patches |
