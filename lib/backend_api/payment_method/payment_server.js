const express = require('express');
const cors = require('cors');
const stripe = require('stripe')(''); //Use your security key here
const app = express();
app.use(express.json());
app.use(cors()); //Enable CORS for all routes

//Route to create payment intent

app.post('/create-payment-intent', async (req, res) => {
    const { amount } = req.body;

    if(!amount || isNaN(amount)) {
        return res.status(400).json({error: 'Invalid amount'});
    }

    try {
        const paymentIntent = await stripe.paymentIntents.create({
            amount: amount * 100, // Stripe uses the smallest currency unit (e.g , cents)
            currency: 'usd',
        });

        res.json({
            clientSecret: paymentIntent.client_secret,
        });
    } catch(error){
        console.error('Error creating payment intent:', error);
        res.status(500).json({error:'Internal Server Error'});
    }

});


//Start the server
const PORT = 3001;
app.listen(PORT, () => console.log(`Server running on port ${PORT}`));