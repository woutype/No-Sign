<p align="center">
  <img src="repo-icon.png" alt="No-Sign" width="128" height="128" style="border-radius: 28px;" />
</p>

<h1 align="center">No-Sign</h1>

<p align="center">
  Удобный on-device подписчик и установщик iOS-приложений с локальной установкой.
</p>

<p align="center">
  <a href="https://github.com/woutype/No-Sign/releases">
    <img src="https://img.shields.io/github/v/release/woutype/No-Sign?include_prereleases&style=flat-square" alt="GitHub Release" />
  </a>
  <a href="https://github.com/woutype/No-Sign/blob/main/LICENSE">
    <img src="https://img.shields.io/github/license/woutype/No-Sign?style=flat-square" alt="License" />
  </a>
</p>

---

## Возможности

- **Подпись на устройстве:** подпись `.ipa` с использованием собственной пары `.p12` и `.mobileprovision`.
- **Локальная установка:** встроенный локальный HTTPS-сервер для быстрой установки приложений прямо на iPhone/iPad, а также поддержка установки через pairing-файл.
- **Менеджер твиков:** импорт, организация и инъекция `.dylib`, `.deb`, `.framework`, `.bundle` и `.appex`.
- **Репозитории AltStore:** добавление и управление источниками, офлайн-кеширование, избранное и отслеживание обновлений.
- **Менеджер загрузок:** фоновые загрузки с поддержкой Live Activities и Dynamic Island.
- **Передача файлов:** встроенный веб-сервер и WebDAV для загрузки `.ipa` и твиков с компьютера.
- **Гибкие настройки подписи:** смена названия, Bundle ID, иконки, поддержка приложения «Файлы» и очистка кэша.
- **Чистый интерфейс:** без рекламы, промо-блоков, трекеров и телеметрии.

## Скачать

Актуальные сборки `.ipa` доступны в разделе **[Releases](https://github.com/woutype/No-Sign/releases)** или во вкладке **[Actions](https://github.com/woutype/No-Sign/actions)** (в артефактах сборки).

## Сборка

Проект автоматически собирается в `.ipa` через GitHub Actions ([`.github/workflows/build.yml`](.github/workflows/build.yml)) при каждом пуше и при ручном запуске.

Для локальной сборки на macOS с Xcode:

```bash
git clone --recurse-submodules https://github.com/woutype/No-Sign.git
cd No-Sign
make
```

## Автор и лицензия

Автор: **[woutype](https://github.com/woutype)**  
Лицензия: [GPL-3.0](./LICENSE)
