import QtQuick 1.0

Rectangle {
    id: main
    width: 320
    height: 480

    Flipable {
        id: container
        height: main.height;
        width: parent.width;
        property int angle: 0
        property bool flipped: true

        // FRONT SIDE HAS APPLICATION
        front:  Rectangle {
            id: basic_view

            anchors.fill: parent
            gradient: Gradient {
                GradientStop { position: 0; color: "black" }
                GradientStop { position: 1.0; color: "gray" }
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "SHOW ME MY FACE APP"
                font.pixelSize: 25
                color: "white"
            }

            Image {
                id: my_picture
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
            }

            Text {
                id: my_name
                anchors.verticalCenter: my_picture.bottom
                anchors.horizontalCenter: parent.horizontalCenter
                text: facebook.me ? facebook.me.name : ""
                color: "silver"
                font.pixelSize: 18
            }
        }

        // BACK SIDE HAS FACEBOOK LOGIN
        back:  Rectangle {
                height: main.height;
                width: main.width;

                Facebook {
                    id: facebook

                    anchors.fill: parent
                    property string displayStyle: "touch" // or "wap"
                    property string applicationId: "<APP ID>"

                    onUserAuthenticated: {
                        console.log("Do something if you want to.");
                        console.log("userId: " + userId);
                        console.log("token: " + token);
                        my_picture.source = facebook.myPicture();
                        container.flipped = !container.flipped;
                    }
                }
        }

        transform: Rotation {
            origin.x: container.width/2; origin.y: container.height/2
            axis.x: 0; axis.y: 1; axis.z: 0 // rotate around y-axis
            angle: container.angle
        }


        states: State {
            name: "back"
            PropertyChanges { target: container; angle: 180 }
            when: container.flipped
        }

        transitions: Transition {
            NumberAnimation { properties: "angle"; duration: 500 }
        }


    }

    Component.onCompleted: {
        facebook.authenticate();
    }
}
