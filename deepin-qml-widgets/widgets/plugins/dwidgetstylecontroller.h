/**
 * Copyright (C) 2015 Deepin Technology Co., Ltd.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 3 of the License, or
 * (at your option) any later version.
 **/

#ifndef DWIDGETSTYLECONTROLLER_H
#define DWIDGETSTYLECONTROLLER_H

#include <QObject>
#include <QDir>
#include <QFile>
#include <QVariant>
#include <QJsonDocument>
#include <QJsonObject>
#include <QFileSystemWatcher>
#include <QLibraryInfo>
#include <QDebug>

class DWidgetStyleController : public QObject
{
    Q_OBJECT

    Q_PROPERTY(QStringList styleList READ getStyleList NOTIFY styleListChanged)
    Q_PROPERTY(QString currentWidgetStyle READ getCurrentWidgetStyle NOTIFY currentWidgetStyleChanged)
    Q_PROPERTY(QString imagesPath READ getImagesPath NOTIFY imagesPathChanged)
    Q_PROPERTY(QJsonObject configObject READ getConfigObject NOTIFY configObjectChanged)

public:
    explicit DWidgetStyleController(QObject *parent = 0);
    ~DWidgetStyleController();

    QJsonObject getConfigObject();
    QString getImagesPath();
    QString getCurrentWidgetStyle();
    QStringList getStyleList();

    Q_INVOKABLE void setCurrentWidgetStyle(const QString & style);
    Q_INVOKABLE bool isAvailableStyle(const QString & style);

signals:
    void currentWidgetStyleChanged();
    void configObjectChanged();
    void imagesPathChanged();
    void styleListChanged();

private slots:
    void configFileChanged(const QString &path);
    void styleDirChanged(const QString &path);

private:
    void init();
    void updateCurrentWidgetStyle(const QString & style);
    QString getResourceDir();
    QString getWidgetStyleFromJson();
    QJsonObject getConfigFromJson();

private:
    QJsonObject m_configObject;
    QString m_imagesPath;
    QString m_currentWidgetStyle;
    QFileSystemWatcher *fileWatcher;

    const QString DEEPIN_WIDGETS_DEFAULT_STYLE = "StyleBlack";
    const QString QT_QML2_IMPORTS_PATH = QLibraryInfo::location(QLibraryInfo::Qml2ImportsPath);
    const QString DEEPIN_WIDGETS_STYLE_PATH = QT_QML2_IMPORTS_PATH + "/Deepin/StyleResources/";
    const QString CONFIG_FILE_DIR = QDir::homePath() + "/.config/DUI/";
    const QString CONFIG_FILE_NAME = CONFIG_FILE_DIR + "WidgetStyle.json";
};

#endif // DWIDGETCONTROLLER_H
