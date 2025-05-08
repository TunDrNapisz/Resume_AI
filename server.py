# save this file as server.py
from flask import Flask, request, jsonify
from flask_cors import CORS

app = Flask(__name__)
CORS(app)  # Bagi access dari Flutter

@app.route('/api/chat', methods=['POST'])
def chat():
    try:
        data = request.get_json()
        messages = data.get('messages', [])

        if not messages:
            return jsonify({'error': 'No messages provided'}), 400

        last_message = messages[-1]['content']
        ai_response = f"AI reply to: {last_message}"

        return jsonify({
            'choices': [
                {
                    'message': {
                        'content': ai_response
                    }
                }
            ]
        }), 200

    except Exception as e:
        print("Error:", e)
        return jsonify({'error': 'Something went wrong.'}), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5005, debug=True) 