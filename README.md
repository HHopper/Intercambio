# Intercambio
Intercambio is a language exchange ddapp that is intended to create a marketplace for language learners and language tutors to connect and exchange funds.

# About the project
Intercambio is a full decentralized language tutoring platform.

It is designed to allow anyone to sign up for either a student or a tutor account - with fully functional wallet capabilities using Ether as the native currency.

Like many other language exchange applications on the market, this product facilitates the connection between buyers and sellers: students and tutors. At its most fundamental, language exchange applications achieve four key things: (1) They create and fund student accounts, (4) they create tutor accounts and manage tutor earnings, (3) they verify that students and teachers have had a language exchange meeting, (4) the transfer funds from one student to the tutor after the lesson happens.

In traditional marketplaces companies tend to extract value in the form of commissions often taken at the time of the occurance of the lesson or upon removal of the funds - frontloading the cost to the tutors themselves. For many such tutors, especially those in deprived areas, a normal commission of 15% for language has a significant impact upon their individual livelihood. This is the primary motivation of Intercambio. (Medium Post: https://medium.com/@huckleberry.ak.hopper/intercambio-a-ethereum-application-for-language-exchange-b2ab858845a8)

In this way, this project is intended simply to facilitate the exact same processes of traditional language tutoring services without the rent-extraction that has become so common in client-server business models around the world.

# How It Works
As a decentralized application, Intercambio simply handles the business logic between buyers and sellers. 

There are only two types of users of this application - both of which have equally important parts to play. Students can create and fund accounts with their public keys. Tutors can do the same. Each of these, including their balances, are included in a public ledger for At this point the lesson has been confirmed and the funds are transferred. Voila!searching later on. A student will select a tutor based upon the language they are interested in learning from the tutor's available time-slots. At this point, to provide an incentive for both the student and tutor to attend their lesson, both parties will stake a predetermined amount of ether in escro until the tutoring lesson occurs. As it stands, the tutor will stake 25% of their rate to and the student will stake the hourly rate for the tutor. Upon scheduling and the inclusion of this transaction on the chain, the student and tutor will have thirty days to complete the lesson. The lesson and stake logic, at this point, only will handle the confirmation of the lesson from a financial perspective and does not integrate (yet) the actual management of the video conversation between the users. Now assuming all goes to plan - that is, the tutor and student skype for an hour to exchange languages - both users will confirm. With a confirmation set, the tutor will call the transfer function and the funds will be withdrawn from escro and deposited into the tutor's account. 


# How to Initialize

Assuming you are using a Linux Ubuntu set-up, you will need the truffle suite as well as the Ganache-cli development blockchain. Following the traditional command line, type: 

$ npm install -g ganache-cli

$ npm install -g truffle


