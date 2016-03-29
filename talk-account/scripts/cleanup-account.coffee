phoneNumber = '18621654252'
emailAddress = 'yong@teambition.com'

mobile = db.mobiles.findOne phoneNumber: phoneNumber
email = db.emails.findOne emailAddress: emailAddress

db.mobiles.remove _id: mobile._id if mobile?._id
db.users.remove _id: mobile.user if mobile?.user

db.emails.remove _id: email._id if email?._id
db.users.remove _id: email.user if email?.user

