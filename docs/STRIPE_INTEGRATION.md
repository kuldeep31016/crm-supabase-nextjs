# Stripe Checkout Integration for Application Fees

This document outlines the implementation flow for integrating Stripe Checkout to handle application fee payments in the LearnLynk CRM system.

## Overview

The Stripe Checkout integration allows users to pay application fees securely through Stripe's hosted checkout page. The flow involves creating a checkout session, redirecting users to Stripe, handling webhook events, and updating the application status accordingly.

## Implementation Flow

### 1. Frontend: Initiate Payment

When a user clicks "Pay Application Fee" on an application page, the frontend calls an Edge Function to create a Stripe Checkout session.

```typescript
// Frontend code
const response = await fetch('/api/create-checkout-session', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({
    application_id: applicationId,
    amount: 5000, // $50.00 in cents
    success_url: `${window.location.origin}/applications/${applicationId}?payment=success`,
    cancel_url: `${window.location.origin}/applications/${applicationId}?payment=cancelled`
  })
})

const { session_url } = await response.json()
window.location.href = session_url
```

### 2. Edge Function: Create Checkout Session

The Edge Function creates a Stripe Checkout Session and stores the payment request information in the database.

```typescript
// supabase/functions/create-checkout-session/index.ts
import Stripe from 'https://esm.sh/stripe@14.21.0'

const stripe = new Stripe(Deno.env.get('STRIPE_SECRET_KEY')!, {
  apiVersion: '2023-10-16',
})

const session = await stripe.checkout.sessions.create({
  payment_method_types: ['card'],
  mode: 'payment',
  line_items: [{
    price_data: {
      currency: 'usd',
      product_data: { 
        name: 'Application Fee',
        description: `Application fee for ${application.program}`
      },
      unit_amount: amount, // Amount in cents
    },
    quantity: 1,
  }],
  metadata: { 
    application_id: applicationId,
    tenant_id: application.tenant_id
  },
  success_url: success_url,
  cancel_url: cancel_url,
})

// Store payment request in database
await supabase
  .from('applications')
  .update({ 
    stripe_session_id: session.id,
    payment_status: 'pending',
    payment_request_id: session.payment_intent
  })
  .eq('id', applicationId)

return new Response(
  JSON.stringify({ session_url: session.url }),
  { status: 200, headers: { 'Content-Type': 'application/json' } }
)
```

### 3. User Completes Payment on Stripe

The user is redirected to Stripe's hosted checkout page where they enter their payment information and complete the transaction.

### 4. Stripe Webhook Handler

After successful payment, Stripe sends a webhook event to our Edge Function endpoint.

```typescript
// supabase/functions/stripe-webhook/index.ts
const event = stripe.webhooks.constructEvent(
  body,
  signature,
  Deno.env.get('STRIPE_WEBHOOK_SECRET')!
)

if (event.type === 'checkout.session.completed') {
  const session = event.data.object
  
  // Extract application_id from metadata
  const applicationId = session.metadata.application_id
  
  // Update payment status to paid
  await supabase
    .from('applications')
    .update({ 
      payment_status: 'paid',
      status: 'under_review', // Move to next stage
      submitted_at: new Date().toISOString()
    })
    .eq('id', applicationId)
  
  // Optionally create a timeline entry or notification
  await supabase
    .from('application_timeline')
    .insert({
      application_id: applicationId,
      event_type: 'payment_received',
      description: 'Application fee payment completed'
    })
}
```

### 5. User Redirected to Success Page

After payment completion, Stripe redirects the user back to the `success_url`. The frontend can then refetch the application data to show the updated payment status.

```typescript
// Frontend: Check for payment success
const searchParams = useSearchParams()
const paymentStatus = searchParams.get('payment')

if (paymentStatus === 'success') {
  // Refetch application data
  queryClient.invalidateQueries(['application', applicationId])
  // Show success notification
}
```

## Key Components

### Database Updates

- **payment_status**: Updated from 'unpaid' → 'pending' → 'paid'
- **stripe_session_id**: Stores the Stripe Checkout Session ID
- **payment_request_id**: Stores the Stripe Payment Intent ID
- **status**: Application status updated to 'under_review' after payment

### Security Considerations

1. **Webhook Signature Verification**: Always verify webhook signatures to ensure requests are from Stripe
2. **Idempotency**: Handle duplicate webhook events gracefully
3. **Error Handling**: Implement proper error handling for failed payments
4. **Service Role Key**: Use Supabase service role key in Edge Functions for database operations

### Environment Variables

```bash
# Supabase Edge Function secrets
STRIPE_SECRET_KEY=sk_test_xxx
STRIPE_WEBHOOK_SECRET=whsec_xxx
```

## Testing

1. Use Stripe test mode for development
2. Test successful payment flow
3. Test cancelled payment flow
4. Test webhook handling with Stripe CLI: `stripe listen --forward-to localhost:54321/functions/v1/stripe-webhook`

## Summary

The Stripe Checkout integration provides a secure, hosted payment solution that:
- Creates a Checkout session and stores payment_request information
- Handles Stripe webhooks to update payment status
- Updates application stage/timeline after successful payment
- Provides a seamless user experience with redirect-based flow

