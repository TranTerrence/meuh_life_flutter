const functions = require('firebase-functions').region('europe-west2');
const admin = require('firebase-admin')
admin.initializeApp()

const db = admin.firestore();

exports.onCreateMessage = functions.firestore
  .document('chatRooms/{chatRoomID}/messages/{message}')
  .onCreate(async (snap, context) => {
    console.log('----------------start function--------------------');

    const doc = snap.data();
    console.log(doc);

    const idFrom = doc.author;
    const chatRoomID = context.params.chatRoomID;

    const contentMessage = doc.content;
    const msgDate = doc.creationDate;


    const chatRoom = (await db.doc('chatRooms/' + chatRoomID).get()).data();
    const userFrom = (await db.doc('users/' + idFrom).get()).data();

    // -Start--- Update last message chatRoom ---- Update the chatRoom lastMessage and date
    db.doc('chatRooms/' + chatRoomID).update({ lastMessage: contentMessage, lastMessageDate: msgDate});
    // -End--- Update last message chatRoom ---- Update the chatRoom lastMessage and date

    // -Start---Send Notifications ---- Get all the users to send notifications
    let usersToPromises = [];
    for (var i = 0; i < chatRoom.users.length; i++) {
      const userID = chatRoom.users[i];
      if (userID === idFrom) { // Do not send notification to the author
        continue;
      }
      usersToPromises.push(db.doc('users/' + userID).get());
    }
    const usersToDocSnapshot = await Promise.all(usersToPromises);

    //Send notifications to each users
    usersToDocSnapshot.forEach(userToDocSnap => {
      let userTo = userToDocSnap.data();
      const payload = {
        notification: {
          title: `Tu as reçu un nouveau message de "${userFrom.firstName}"`,
          body: contentMessage,
          badge: '1',
          sound: 'default'
        },
        data: {
          "click_action": "FLUTTER_NOTIFICATION_CLICK",
          "sound": "default",
          "status": "done",
          "screen": "screenA", //TODO: Put the screen to open
        },
      }
      // Let push to the target device
      admin.messaging()
        .sendToDevice(userTo.pushToken, payload)
        .then(response => {
          console.log('Successfully sent message to:', user.firstName, response);
          return;
        })
        .catch(error => {
          console.log('Error sending message:', error)
        })
    });

    // -END---Send Notifications ----

  });


exports.reactionsCount = functions.firestore.document('posts/{postID}/reactions/{userID}')
  .onWrite((change, context) => {
    const postID = context.params.postID;
    const countDocRef = 'posts/' + postID;
    console.log('postID ', postID, 'countDocREF ', countDocRef);
    if (!change.before.exists) {
      // New document Created : add one to count
      console.log('Increment +1 ');
      db.doc(countDocRef).update({ reactionCount: FieldValue.increment(1) });
    } else if (change.before.exists && change.after.exists) {
      // Updating existing document : Do nothing
      // TODO later: Manage the type of reaction to show
    } else if (!change.after.exists) {
      // Deleting document : subtract one from count
      console.log('Decrement -1 ');
      db.doc(countDocRef).update({ reactionCount: FieldValue.increment(-1) });
    }

  });

exports.commentsCount = functions.firestore.document('posts/{postID}/comments/{commentID}')
  .onWrite((change, context) => {
    const postID = context.params.postID;
    const countDocRef = 'posts/' + postID;
    console.log('postID ', postID, 'countDocREF ', countDocRef);
    if (!change.before.exists) {
      // New document Created : add one to count
      console.log('Increment +1 ');
      db.doc(countDocRef).update({ commentCount: FieldValue.increment(1) });
    } else if (change.before.exists && change.after.exists) {
      // Updating existing document : Do nothing
      // TODO later: Manage the type of reaction to show
    } else if (!change.after.exists) {
      // Deleting document : subtract one from count
      console.log('Decrement -1 ');
      db.doc(countDocRef).update({ commentCount: FieldValue.increment(-1) });
    }

  });

