importScripts("https://www.gstatic.com/firebasejs/8.10.1/firebase-app.js");
importScripts("https://www.gstatic.com/firebasejs/8.10.1/firebase-messaging.js");

firebase.initializeApp({
    apiKey: "AIzaSyCodd-QN4TJGNJx4EDBFITzQSzpabPY8JA",
    authDomain: "dirt2tidy-55848.firebaseapp.com",
    projectId: "dirt2tidy-55848",
    storageBucket: "dirt2tidy-55848.firebasestorage.app",
    messagingSenderId: "185184234632",
    appId: "1:185184234632:web:83be7ebd4116fb7dc1c33d",
    measurementId: ""
});

const messaging = firebase.messaging();

messaging.setBackgroundMessageHandler(function (payload) {
    const promiseChain = clients
        .matchAll({
            type: "window",
            includeUncontrolled: true
        })
        .then(windowClients => {
            for (let i = 0; i < windowClients.length; i++) {
                const windowClient = windowClients[i];
                windowClient.postMessage(payload);
            }
        })
        .then(() => {
            const title = payload.notification.title;
            const options = {
                body: payload.notification.score
            };
            return registration.showNotification(title, options);
        });
    return promiseChain;
});
self.addEventListener('notificationclick', function (event) {
    console.log('notification received: ', event)
});