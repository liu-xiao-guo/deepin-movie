/**
 * Copyright (C) 2015 Deepin Technology Co., Ltd.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 3 of the License, or
 * (at your option) any later version.
 **/

#include "dwidgetstylecontroller.h"
#include <QDebug>
#include <QProcessEnvironment>

DWidgetStyleController::DWidgetStyleController(QObject *parent) : QObject(parent)
{
    init();
}

void DWidgetStyleController::init()
{
    //makesure path exist
    QDir configDir;
    qDebug() << "CONFIG_FILE_DIR: " << CONFIG_FILE_DIR;

    if (!configDir.exists(CONFIG_FILE_DIR))
    {
        qDebug() << "CONFIG_FILE_DIR does not exit!";
        configDir.mkpath(CONFIG_FILE_DIR);
    }
    //makesure config-file exits
    QFile file(CONFIG_FILE_NAME);
    qDebug() << "CONFIG_FILE_NAME: " << CONFIG_FILE_NAME;

    if (!file.exists(CONFIG_FILE_NAME))
    {
        qDebug() << "CONFIG_FILE_NAME does not exist!";
        updateCurrentWidgetStyle(DEEPIN_WIDGETS_DEFAULT_STYLE);
    }

    m_currentWidgetStyle = getWidgetStyleFromJson();
    m_imagesPath = getImagesPath();
    m_configObject = getConfigFromJson();

    fileWatcher = new QFileSystemWatcher(this);
    fileWatcher->addPath(CONFIG_FILE_NAME);
    fileWatcher->addPath(DEEPIN_WIDGETS_STYLE_PATH);
    connect(fileWatcher, SIGNAL(fileChanged(QString)), this, SLOT(configFileChanged(QString)));
    connect(fileWatcher, SIGNAL(directoryChanged(QString)), this, SLOT(styleDirChanged(QString)));
}

void DWidgetStyleController::configFileChanged(const QString &path)
{
    if (path == CONFIG_FILE_NAME)
    {
        m_currentWidgetStyle = getWidgetStyleFromJson();
        emit currentWidgetStyleChanged();

        m_imagesPath = getImagesPath();
        emit imagesPathChanged();

        m_configObject = getConfigFromJson();
        emit configObjectChanged();
    }
}

void DWidgetStyleController::styleDirChanged(const QString &path)
{
    if (path == DEEPIN_WIDGETS_STYLE_PATH)
    {
        emit styleListChanged();
    }
}

QJsonObject DWidgetStyleController::getConfigObject()
{
    return m_configObject;
}

QString DWidgetStyleController::getImagesPath()
{
#ifdef SNAP_APP
    QProcessEnvironment env = QProcessEnvironment::systemEnvironment();
    QString SNAP = env.value("SNAP");
    return SNAP + getResourceDir() + "/images/";
#else
    QString temp = getResourceDir() + "/images/";
    qDebug() << "getImagesPath: " << temp;
    return getResourceDir() + "/images/";
#endif
}

QString DWidgetStyleController::getCurrentWidgetStyle()
{
    const QString style = qgetenv("DUI_STYLE").constData();
    if(style !="" && isAvailableStyle(style)){
        return style;
    }
    return m_currentWidgetStyle;
}

QStringList DWidgetStyleController::getStyleList()
{
    QDir tmpDir(DEEPIN_WIDGETS_STYLE_PATH);
    QStringList styleDirList;
    QStringList tmpDirList = tmpDir.entryList(QDir::Dirs | QDir::NoDotAndDotDot);
    for (int i = 0; i < tmpDirList.count(); i ++)
    {
        if (QFile::exists(DEEPIN_WIDGETS_STYLE_PATH + tmpDirList.at(i) + "/images")
                && QFile::exists(DEEPIN_WIDGETS_STYLE_PATH + tmpDirList.at(i) + "/style.json"))
        {
            styleDirList.append(tmpDirList.at(i));
        }
    }

    return styleDirList;
}

void DWidgetStyleController::setCurrentWidgetStyle(const QString & style)
{
    if (!isAvailableStyle(style))
        return;

    m_currentWidgetStyle = style;
    updateCurrentWidgetStyle(style);
    emit currentWidgetStyleChanged();
}

bool DWidgetStyleController::isAvailableStyle(const QString &style)
{
    return getStyleList().indexOf(style) != -1;
}

void DWidgetStyleController::updateCurrentWidgetStyle(const QString & style)
{
    QFile file(CONFIG_FILE_NAME);
    if (!file.exists(CONFIG_FILE_NAME))
    {
        file.open(QIODevice::WriteOnly);
        file.close();
    }

    QJsonObject styleObj;
    styleObj.insert("CurrentWidgetStyle", style);

    QJsonDocument jsonDocument;
    jsonDocument.setObject(styleObj);

    if (file.open(QIODevice::WriteOnly | QIODevice::Truncate))
    {
        file.write(jsonDocument.toJson(QJsonDocument::Compact));
        file.close();
    }
    else
        qDebug() << "Open DUI style-config file error!";
}

QString DWidgetStyleController::getResourceDir()
{
    return DEEPIN_WIDGETS_STYLE_PATH + getCurrentWidgetStyle();
}

QString DWidgetStyleController::getWidgetStyleFromJson()
{
    QFile file(CONFIG_FILE_NAME);
    if (!file.exists(CONFIG_FILE_NAME))
    {
        file.open(QIODevice::WriteOnly);
        file.close();
    }

    if (!file.open(QIODevice::ReadOnly))
        return DEEPIN_WIDGETS_DEFAULT_STYLE;

    //if got error,return black style
    QJsonParseError jsonError;
    QJsonDocument parseDoucment = QJsonDocument::fromJson(file.readAll(), &jsonError);

    file.close();

    if(jsonError.error == QJsonParseError::NoError)
    {
        if(parseDoucment.isObject())
        {
            QJsonObject obj = parseDoucment.object();
            if(obj.contains("CurrentWidgetStyle"))
            {
                QJsonValue styleValue = obj.take("CurrentWidgetStyle");
                if(styleValue.isString())
                    return styleValue.toVariant().toString();
            }
            return DEEPIN_WIDGETS_DEFAULT_STYLE;
        }
        return DEEPIN_WIDGETS_DEFAULT_STYLE;
    }
    else
        return DEEPIN_WIDGETS_DEFAULT_STYLE;
}

QJsonObject DWidgetStyleController::getConfigFromJson()
{
    QJsonObject tmpObj;
#ifdef SNAP_APP
    QProcessEnvironment env = QProcessEnvironment::systemEnvironment();
    QString SNAP = env.value("SNAP");
    qDebug() << "style path: " << SNAP + getResourceDir() + "/images/";
    QString fileName = SNAP + getResourceDir() + "/style.json";
    qDebug() << "fileName: " << fileName;
#else
    QString fileName = getResourceDir() + ;
#endif

    QFile file(fileName);

    if (!file.exists(fileName))
    {
        qWarning() << "[Error]: No such style config file!";
        return tmpObj;
    }

    if (!file.open(QIODevice::ReadOnly))
    {
        qWarning() << "[Error]:Open style config file for read error!";
        return tmpObj;
    }

    QJsonDocument parseDoucment = QJsonDocument::fromJson(file.readAll());

    file.close();

    if(parseDoucment.isObject())
        tmpObj = parseDoucment.object();
    else
        qWarning() << "[Error]:Style config file value unavailable!";

    return tmpObj;
}

DWidgetStyleController::~DWidgetStyleController()
{

}

