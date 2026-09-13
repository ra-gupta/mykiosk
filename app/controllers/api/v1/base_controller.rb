module Api
  module V1
    # Android sends `Authorization: Bearer <token>` from POST /api/v1/session.
    class BaseController < ActionController::API
      include Rails.application.routes.url_helpers
      before_action :authenticate

      private
        def authenticate
          Current.session = Session.find_by(token: request.headers["Authorization"]&.remove("Bearer "))
          render json: { error: "Unauthorized" }, status: :unauthorized unless Current.session
        end

        def session_json(session)
          user = session.user
          { token: session.token,
            user: { id: user.id, email_address: user.email_address, phone_number: user.phone_number, owner: user.owner? } }
        end

        def product_json(product)
          product.as_json(only: %i[ id name price mrp unit stock ]).merge(
            image_url: product_image_url(product), discount_percentage: product.discount_percentage)
        end

        def order_json(order)
          order.as_json(only: %i[ id status total created_at ] + Order::FIELDS).merge(
            customer_name: order.user.display_name,
            delivery_promise: order.delivery_promise,
            next_status: order.next_status,
            items: order.order_items.map { |item|
              { product_id: item.product_id, name: item.product.name, quantity: item.quantity, price: item.price }
            }
          )
        end

        def product_image_url(product)
          if product.photo.attached?
            url_for(product.photo)
          elsif product.image.present?
            "#{request.base_url}#{ActionController::Base.helpers.image_path(product.image)}"
          end
        end

        def default_url_options = { host: request.host, port: request.optional_port, protocol: request.protocol }
    end
  end
end
