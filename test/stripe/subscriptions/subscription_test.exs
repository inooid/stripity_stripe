defmodule Stripe.SubscriptionTest do
  use Stripe.StripeCase, async: true

  describe "retrieve/2" do
    test "retrieves a subscription" do
      assert {:ok, %Stripe.Subscription{}} = Stripe.Subscription.retrieve("sub_123")
      assert_stripe_requested(:get, "/v1/subscriptions/sub_123")
    end
  end

  describe "create/2" do
    test "creates a subscription" do
      params = %{
        application_fee_percent: 5,
        customer: "cus_123",
        items: [
          %{
            plan: "ruby-express-932",
            quantity: 1
          }
        ]
      }

      assert {:ok, %Stripe.Subscription{}} =
               Stripe.Subscription.create(params, connect_account: "acct_123")

      assert_stripe_requested(:post, "/v1/subscriptions")
    end

    test "fails with source param [since 2018-08-23]" do
      params = %{
        customer: "cus_123",
        source: "tok_123",
        items: [
          %{
            plan: "ruby-express-932",
            quantity: 1
          }
        ]
      }

      assert {:error, %Stripe.Error{}} = Stripe.Subscription.create(params)

      assert_stripe_requested(:post, "/v1/subscriptions")
    end
  end

  describe "update/2" do
    test "updates a subscription" do
      params = %{metadata: %{foo: "bar"}}
      assert {:ok, subscription} = Stripe.Subscription.update("sub_123", params)
      assert_stripe_requested(:post, "/v1/subscriptions/#{subscription.id}")
    end

    test "fails with source param [since 2018-08-23]" do
      params = %{source: "tok_124", metadata: %{foo: "bar"}}
      assert {:error, %Stripe.Error{}} = Stripe.Subscription.update("sub_123", params)
      assert_stripe_requested(:post, "/v1/subscriptions/sub_123")
    end
  end

  describe "list/2" do
    test "lists all subscriptions" do
      assert {:ok, %Stripe.List{data: subscriptions}} = Stripe.Subscription.list()
      assert_stripe_requested(:get, "/v1/subscriptions")
      assert is_list(subscriptions)
      assert %Stripe.Subscription{} = hd(subscriptions)
    end
  end

  describe "search/2" do
    test "searches subscriptions" do
      query = "name:'fakename' AND metadata['foo']:'bar'"
      assert {:ok, %Stripe.SearchResult{data: subscriptions}} =
              Stripe.Subscription.search(%{query: query})

      assert_stripe_requested(:get, "/v1/subscriptions/search", query: [query: query])
      assert is_list(subscriptions)
      assert %Stripe.Subscription{} = hd(subscriptions)
    end
  end

  describe "delete_discount/2" do
    test "deletes a subscription's discount" do
      {:ok, subscription} = Stripe.Subscription.retrieve("sub_123")
      assert_stripe_requested(:get, "/v1/subscriptions/#{subscription.id}")

      assert {:ok, _} = Stripe.Subscription.delete_discount("sub_123")
      assert_stripe_requested(:delete, "/v1/subscriptions/#{subscription.id}/discount")
    end
  end
end
