import QtQuick 2.1
import SddmComponents 2.0
import QtMultimedia 5.7

import "components"



Rectangle {
    // Main Container
    id: container

    LayoutMirroring.enabled: Qt.locale().textDirection == Qt.RightToLeft
    LayoutMirroring.childrenInherit: true

    property int sessionIndex: session.index

    // Inherited from SDDMComponents
    TextConstants {
        id: textConstants
    }

    // Set SDDM actions
    Connections {
        target: sddm
        onLoginSucceeded: {
        }

        onLoginFailed: {
            error_message.color = "#dc322f"
            error_message.text = textConstants.loginFailed
        }
    }

    // Set Font
    FontLoader {
        id: textFont; name: config.displayFont
    }

    // Background Fill
    Rectangle {
        anchors.fill: parent
        color: "black"
    }

    property bool playedAnimation: false;

    // Set Background Video1
    MediaPlayer {
        id: mediaplayer1
        autoPlay: true; muted: true
        playlist: Playlist {
            id: playlist1
            playbackMode: Playlist.Random
            onLoaded: {

            mediaplayer1.play() }
        }

        onPositionChanged: {

          if(position >= 1 && position <= 1000 && !playedAnimation) {
              fadeInVideo.start();
              playedAnimation: true;
          }

          if(position >= 24000 && position <= 25000) {
              fadeOutVideoB.start();
          }

          if(position >= 26000 && position <= 27800) {
              /*mediaplayer1.stop();*/
              mediaplayer1.seek(0);
              playlist1.next();
              mediaplayer1.play();
              fadeImage.opacity = 1;
              fadeImageB.opacity = 0;
          }
        }
    }

    VideoOutput {
        id: video1
        fillMode: VideoOutput.PreserveAspectCrop
        anchors.fill: parent; source: mediaplayer1
        opacity: 0
        MouseArea {
            id: mouseArea1
            anchors.fill: parent;
            onPressed: {

                fader1.state = fader1.state == "off" ? "on" : "off" ;
             }
             cursorShape: Qt.BlankCursor
        }
        Keys.onPressed: {
            fader1.state = "on";
            if (username_input_box.text == "")
                username_input_box.focus = true
            else
                password_input_box.focus = true
        }
    }

    WallpaperFader {
        id: fader1
        visible: true
        anchors.fill: parent
        state: "off"
        source: video1
        mainStack: login_container
        footer: login_container
    }

    Image {
        id: fadeImage
        anchors.fill: parent
        source: config.background
        fillMode: Image.PreserveAspectCrop

        NumberAnimation on opacity {
          running: false
          id: fadeInVideo
          from: 1
          to: 0
          duration: 1500
        }

        NumberAnimation on opacity {
          running: false
          id: fadeOutVideo
          from: 0
          to: 1
          duration: 1500
        }
    }

/* Workaround because on boot the fadeOut does not work with only one image besides that it does in Test Mode */
    Image {
        id: fadeImageB
        anchors.fill: parent
        source: config.background
        fillMode: Image.PreserveAspectCrop
        opacity: 0
        NumberAnimation on opacity {
          running: false
          id: fadeOutVideoB
          from: 0
          to: 1
          duration: 1500
        }
    }

    // Clock and Login Area
    Rectangle {
        id: rectangle
        anchors.fill: parent
        color: "transparent"

        Clock {
            id: clock
            y: parent.height * config.relativePositionY - clock.height / 2
            x: parent.width * config.relativePositionX - clock.width / 2
            color: "white"
            timeFont.family: textFont.name
            dateFont.family: textFont.name
        }

        Rectangle {
            id: login_container

            y: clock.y + clock.height + 30
            width: clock.width
            height: parent.height * 0.08
            color: "transparent"
            anchors.left: clock.left

            Rectangle {
                id: username_row
                height: parent.height * 0.36
                color: "transparent"
                anchors.left: parent.left
                anchors.leftMargin: 0
                anchors.right: parent.right
                anchors.rightMargin: 0
                transformOrigin: Item.Center
                anchors.margins: 10

                Text {
                    id: username_label
                    width: parent.width * 0.27
                    height: parent.height * 0.66
                    horizontalAlignment: Text.AlignLeft
                    font.family: textFont.name
                    font.bold: true
                    font.pixelSize: 16
                    color: "white"
                    text: "Username"
                    anchors.verticalCenter: parent.verticalCenter
                }

                TextBox {
                    id: username_input_box
                    height: parent.height
                    text: userModel.lastUser
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: username_label.right
                    anchors.leftMargin: config.usernameLeftMargin
                    anchors.right: parent.right
                    anchors.rightMargin: 0
                    font: textFont.name
                    color: "#25000000"
                    borderColor: "transparent"
                    textColor: "white"

                    Keys.onPressed: {
                        if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                            sddm.login(username_input_box.text, password_input_box.text, session.index)
                            event.accepted = true
                        }
                    }

                    KeyNavigation.backtab: password_input_box
                    KeyNavigation.tab: password_input_box
                }
            }

            Rectangle {
                id: password_row
                y: username_row.height + 10
                height: parent.height * 0.36
                color: "transparent"
                anchors.right: parent.right
                anchors.rightMargin: 0
                anchors.left: parent.left
                anchors.leftMargin: 0

                Text {
                    id: password_label
                    width: parent.width * 0.27
                    text: textConstants.password
                    anchors.verticalCenter: parent.verticalCenter
                    horizontalAlignment: Text.AlignLeft
                    font.family: textFont.name
                    font.bold: true
                    font.pixelSize: 16
                    color: "white"
                }

                PasswordBox {
                    id: password_input_box
                    height: parent.height
                    font: textFont.name
                    color: "#25000000"
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.right: parent.right
                    anchors.rightMargin: parent.height // this sets button width, this way its a square
                    anchors.left: password_label.right
                    anchors.leftMargin: config.passwordLeftMargin
                    borderColor: "transparent"
                    textColor: "white"
                    tooltipBG: "#25000000"
                    tooltipFG: "#dc322f"
                    image: "components/resources/warning_red.png"
                    onTextChanged: {
                        if (password_input_box.text == "") {
                            clear_passwd_button.visible = false
                        }
                        if (password_input_box.text != "" && config.showClearPasswordButton != "false") {
                            clear_passwd_button.visible = true
                        }
                    }

                    Keys.onPressed: {
                        if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                            sddm.login(username_input_box.text, password_input_box.text, session.index)
                            event.accepted = true
                        }
                    }

                    KeyNavigation.backtab: username_input_box
                    KeyNavigation.tab: login_button
                }

                Button {
                    id: clear_passwd_button
                    height: parent.height
                    width: parent.height
                    color: "transparent"
                    text: "x"
                    font: textFont.name

                    border.color: "transparent"
                    border.width: 0
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.right: parent.right
                    anchors.leftMargin: 0
                    anchors.rightMargin: parent.height

                    disabledColor: "#dc322f"
                    activeColor: "#393939"
                    pressedColor: "#2aa198"

                    onClicked: {
                        password_input_box.text=''
                        password_input_box.focus = true
                    }
                }

                Button {
                    id: login_button
                    height: parent.height
                    color: "#393939"
                    text: ">"
                    border.color: "#00000000"
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: password_input_box.right
                    anchors.right: parent.right
                    disabledColor: "#dc322f"
                    activeColor: "#268bd2"
                    pressedColor: "#2aa198"
                    textColor: "white"
                    font: textFont.name

                    onClicked: sddm.login(username_input_box.text, password_input_box.text, session.index)

                    KeyNavigation.backtab: password_input_box
                    KeyNavigation.tab: reboot_button
                }

                Text {
                    id: error_message
                    height: parent.height
                    font.family: textFont.name
                    font.pixelSize: 12
                    color: "white"
                    anchors.top: password_input_box.bottom
                    anchors.left: password_input_box.left
                    anchors.leftMargin: 0
                }
            }

        }
    }

    Image {
        anchors.fill: parent
        source: config.background
        fillMode: Image.PreserveAspectCrop

        NumberAnimation on opacity {
          id: createTextAnimation
          from: 1
          to: 0
          duration: 1500
        }
        Component.onCompleted: createTextAnimation.start()
    }

    // Top Bar
    Rectangle {
        id: actionBar
        width: parent.width
        height: parent.height * 0.04
        anchors.top: parent.top;
        anchors.horizontalCenter: parent.horizontalCenter
        color: "transparent"
        visible: config.showTopBar != "false"

        Row {
            id: row_left
            anchors.left: parent.left
            anchors.margins: 5
            height: parent.height
            spacing: 10

            ComboBox {
                id: session
                width: 145
                height: 20
                anchors.verticalCenter: parent.verticalCenter
                color: "transparent"
                arrowColor: "transparent"
                textColor: "#505050"
                borderColor: "transparent"
                hoverColor: "#5692c4"

                model: sessionModel
                index: sessionModel.lastIndex

                KeyNavigation.backtab: shutdown_button
                KeyNavigation.tab: password_input_box
            }

            ComboBox {
                id: language

                model: keyboard.layouts
                index: keyboard.currentLayout
                width: 50
                height: 20
                anchors.verticalCenter: parent.verticalCenter
                color: "transparent"
                arrowColor: "transparent"
                textColor: "white"
                borderColor: "transparent"
                hoverColor: "#5692c4"

                onValueChanged: keyboard.currentLayout = id

                Connections {
                    target: keyboard

                    onCurrentLayoutChanged: combo.index = keyboard.currentLayout
                }

                rowDelegate: Rectangle {
                    color: "transparent"

                    Text {
                        anchors.margins: 4
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom

                        verticalAlignment: Text.AlignVCenter

                        text: modelItem ? modelItem.modelData.shortName : "zz"
                        font.family: textFont.name
                        font.pixelSize: 14
                        //color: "white"
                        color: "#505050"
                    }
                }
                KeyNavigation.backtab: session
                KeyNavigation.tab: username_input_box
            }
        }

        Row {
            id: row_right
            height: parent.height
            anchors.right: parent.right
            anchors.margins: 5
            spacing: 10

            ImageButton {
                id: reboot_button
                height: parent.height
                source: "components/resources/reboot.svg"

                visible: sddm.canReboot
                onClicked: sddm.reboot()
                KeyNavigation.backtab: login_button
                KeyNavigation.tab: shutdown_button
            }

            ImageButton {
                id: shutdown_button
                height: parent.height
                source: "components/resources/shutdown.svg"
                visible: sddm.canPowerOff
                onClicked: sddm.powerOff()
                KeyNavigation.backtab: reboot_button
                KeyNavigation.tab: session
            }
        }
    }

    Component.onCompleted: {
        video1.focus = true

        // load and randomize playlist
        var time = parseInt(new Date().toLocaleTimeString(Qt.locale(),'h'))
        if ( time >= 5 && time <= 17 ) {
            playlist1.load(Qt.resolvedUrl(config.background_day), 'm3u')

        } else {
            playlist1.load(Qt.resolvedUrl(config.background_night), 'm3u')
        }

        for (var k = 0; k < Math.ceil(Math.random() * 10) ; k++) {
            playlist1.shuffle()
        }

        if (config.showLoginButton == "false") {
            login_button.visible = false
            password_input_box.anchors.rightMargin = 0
            clear_passwd_button.anchors.rightMargin = 0
        }
        clear_passwd_button.visible = false
    }
}
