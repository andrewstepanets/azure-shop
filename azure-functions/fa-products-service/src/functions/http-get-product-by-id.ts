import {
  HttpRequest,
  HttpResponseInit,
  InvocationContext,
} from '@azure/functions';
import { app } from '@azure/functions';

type Product = {
  id: string;
  title: string;
  description: string;
  price: number;
};

const products: Product[] = [
  { id: '1', title: 'Product A', description: 'Description A', price: 100 },
  { id: '2', title: 'Product B', description: 'Description B', price: 200 },
];

export async function getProductById(
  request: HttpRequest,
  context: InvocationContext
): Promise<HttpResponseInit> {
  const productId = request.params['productId'];
  const product = products.find((p) => p.id === productId);

  if (product) {
    context.log(`Product found for id ${productId}`);
    return {
      status: 200,
      body: JSON.stringify(product),
    };
  } else {
    context.log(`Product not found for id ${productId}`);
    return {
      status: 404,
      body: 'Product not found',
    };
  }
}

app.http('getProductById', {
  methods: ['GET'],
  route: 'products/{productId}',
  handler: getProductById,
});
