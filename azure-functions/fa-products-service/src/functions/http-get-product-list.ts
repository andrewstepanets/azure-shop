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

export async function getProductList(
  request: HttpRequest,
  context: InvocationContext
): Promise<HttpResponseInit> {
  context.log(`Returning ${products.length} products`);

  return {
    status: 200,
    body: JSON.stringify(products),
  };
}

app.http('getProductList', {
  methods: ['GET'],
  route: 'products',
  handler: getProductList,
});
