const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const Product= require('./models/Product');

const app = express();

//Middleware
app.use(cors());
app.use(express.json());

//MongoDB Connection
const mongoURI = 'your_mongodb_url';

mongoose.connect(mongoURI, {
    useNewUrlParser: true,
    useUnifiedTopology: true,
})
.then(() => console.log('MongoDB Connected'))
.catch((err) => console.error('MongoDB connection error:', err));


//Routes
// Get all products
app.get('/products', async (req, res) => {
    try{
        const products = await Product.find();
        res.json(products);
    } catch(err) {
        res.status(500).json({message: 'Error fetching products', error: err.message});
    }
});

//Get a product by ID
app.get('/products/:id', async (req, res) => {
    try{
        const product = await Product.findOne({id: req.params.id});
        if(!product){
            return res.status(404).json({message: 'Product not found'});
        }
        res.json(product);
    } catch(err){
        res.status(500).json({message: 'Error fetching product', error: err.message});
    }
});

//Add a new product
app.post('/products', async (req, res) => {
    try{
        const product = new Product(req.body);
        await product.save();
        res.status(201).json(product);
    } catch(err) {
        res.status(400).json({message: 'Error creating product', error: err.message});
    }
});

//Update a product
app.put('/products/:id', async (req, res) => {
    try{
        const product = await Product.findOneAndUpdate({
            id: req.params.id},
            req.body,
            {new: true} // returns the updated document
        );
        if(!product){
            return res.status(404).json({message: 'Product not found'});
        }
        res.json(product);
    } catch(err){
        res.status(400).json({message: 'Error updating product', error:err.message});
    }
});

//Delete a product
app.delete('/products/:id', async (req, res) => {
    try{
        const product = await Product.findOneAndDelete({id: req.params.id});
        if(!product){
            return res.status(404).json({message: 'Product not found'});
        }
        res.json({message:'Product deleted'});
    } catch(err){
        res.status(500).json({message: 'Error deleting product', error: err.message});
    }
});

// Get products by category
app.get('/products/category/:category', async (req, res) => {
    try {
        const category = req.params.category;
        const products = await Product.find({category});
        if(products.length === 0) {
            return res.status(404).json({message: 'No products found for this category'});
        }
        res.json(products);
    } catch(err){
        res.status(500).json({message: 'Error fetching products by category', error: err.message});
    }
});

// Start Server
const PORT = 5000;
app.listen(PORT, () => console.log(`Server running on port ${PORT}`));


