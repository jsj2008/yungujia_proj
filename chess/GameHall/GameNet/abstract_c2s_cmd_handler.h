#ifndef __ABSTRACT_C2S_CMD_HANDLER_H_
#define __ABSTRACT_C2S_CMD_HANDLER_H_

#include "common/SDLogger.h"
#include "common/GameNetInf.h"
#include "asynio/asyn_io_device.h"
#include "asynio/asyn_io_operation.h"
#include "asynio/asyn_io_handler.h"
#include <list>
#include <vector>
#include <map>

const int FIXED_OPERATION_BUFFER_LENGTH = 256 * 1024;
const int OPERTION_POOL_SIZE = 1;
const int EXTRA_BUFFER_SIZE	= 8192;

class abstract_c2s_cmd_handler;
class pooled_operation_manager;

class vdt_io_operation : public asyn_io_operation
{
public:
	vdt_io_operation(abstract_c2s_cmd_handler *handler_ptr, unsigned long buffer_len = 0, bool is_pooled_operation = false);
	virtual ~vdt_io_operation() { }

	bool is_pooled_operation() { return _is_pooled_operation; }
	void set_pooled_operation_manager(pooled_operation_manager* pooled_mgr)
	{
		if(_is_pooled_operation)
			_pooled_mgr = pooled_mgr;
	}
	pooled_operation_manager* get_pooled_operation_mgr() { return _pooled_mgr; }

public:
	unsigned long			_data_total_len;// ���ڼ�¼socket���ͣ����գ�������ʱ������ԭʼ����
	unsigned long			_data_pos;		// ���ڼ�¼socket���ͣ����գ�������ʱ������λ��
	unsigned long			_data_len;		// ���ڼ�¼socket���ͣ����գ�������ʱ�����ݳ���
	bool					_is_header_received;  // ��ͷ�Ƿ������
	string					_cmd_desc;  // tracer����ʱ���Ż�ʹ�ô��ֶ�

private:
	bool _is_pooled_operation;
	pooled_operation_manager* _pooled_mgr;
};

class pooled_operation_manager
{
public:
	pooled_operation_manager(int max_pooled_size);

	bool is_pool_empty() { return _pooled_operation_ptrs.empty(); }
	bool add_to_pool(vdt_io_operation* operation_ptr);
	vdt_io_operation* fetch_from_pool();
	void fetch_specified_operation(vdt_io_operation* operation_ptr);
	void clear();
	int max_pooled_size() {return _max_pooled_size;}
	int cur_pooled_size() {return _cur_pooled_size;}

private:
	std::list<vdt_io_operation*> _pooled_operation_ptrs;
	std::set<vdt_io_operation*> _unique_operation_ptrs;
	int _max_pooled_size;
	int _cur_pooled_size;

	DECL_LOGGER;
};

#define D_SEND_ERROR 0
#define D_RECV_ERROR 1
#define D_CONN_ERROR 2
#define D_PACKET_ERROR 3
#define D_SENDPOOL_ERROR 4

class abstract_c2s_cmd_handler :	public asyn_io_handler
{
public:
	abstract_c2s_cmd_handler(const std::string &host, unsigned short port, bool is_session_conn );
	virtual ~abstract_c2s_cmd_handler(void);

public:
	virtual void handle_io_complete(asyn_io_operation *operation_ptr);

	bool is_session_connection() { return _is_session_conn; }
    void close_connection();

    // ��������(�����UDP����DNS��ѯ)
    virtual void connect() = 0;
    void receive(); // ���Խ�������

	virtual int connect_type() = 0;
protected:
	virtual void before_exit_io_complete(asyn_io_operation *operation_ptr, bool has_more_cmd) { }

	// cmd_ptr��ӵ��Ȩ�������
	void execute_cmd( IGameCommand* cmd_ptr );
	vdt_io_operation* create_cmd_operation( IGameCommand* cmd_ptr );
	
	// �������ڶ����е�����
	bool send_queued_command();
	
	// ���ӳɹ���(��DNS�����ɹ���)���¼�����
	virtual void handle_connect_result( asyn_io_operation* result );
	virtual int get_recv_operation_num() const { return 1; }

	// ����_operation_ptr�Ļ����������ӶԶ�
	void send(vdt_io_operation* sending_operation_ptr);
	// �ڷ���һ������ǰ�Ļص��������������������޸ģ��������ñ������Է�IP�ֶΣ�
	virtual bool before_send( asyn_io_operation*  opt_ptr, unsigned long & encode_length );

	// ��Ϊ�жദ����socket recv���쳣�Ĵ�������������̫�࣬�����ܽᵽһ��������
	void socket_receive( asyn_io_operation *operation_ptr, unsigned long expected_bytes,
		unsigned long buffer_pos = 0, bool must_receive_expected = true ); // ���һ���������ƶ�����ѭ��������ָ�����ֽ���	

	void handle_received( asyn_io_operation *result, unsigned long received_bytes);					// ����recv���첽����
	void decode_response( char *buffer_ptr, unsigned long buffer_len );// recv������������,decode����֪ͨ�ϲ�

	virtual int init_header_io_opeation(int header_len);
	virtual void init_body_io_operation(int header_len, int body_len);

	std::string get_socket_address(); // �����������,��ȡSOCKET��ַ

protected:
	// response_ptr��ӵ��Ȩ�������
	virtual bool handle_response( IGameCommand *response_ptr ) = 0;

protected:
    void init_operation_pool();
    void uninit_operation_pool();
    void close_asyn_operation_ptr(asyn_io_operation* operation_ptr);

public:
	void close();

protected:
//	IGameCommand*			_cmd_ptr_received;	// ��server���յ�������
//	unsigned __int32        _cmd_sequence;      // ������������к�

	enum tag_status
	{
		status_idle,		// ����
		status_connecting,	// ��������
		status_sending,		// ���ڷ���
		status_receiving,	// ���ڽ���
	};
	
	bool					_is_connected;
	bool					_allow_receive;  // ������server������һ��������������
	bool					_is_receiving;

	// unsigned int					_retry_times;		// tcp����ʧ�ܺ�����Դ���
	// asyn_socks_socket_device*	_sock5_socket_ptr;	// ʹ��sock5����ʱ��sock5 socket ����ָ��
	asyn_io_device*		_socket_ptr;	// ִ������������첽socket����ָ��


	pooled_operation_manager* _pooled_send_operation_mgr;
	std::vector<vdt_io_operation*> _all_sending_operation; // ���е��첽operation����أ����ڷ���

	pooled_operation_manager* _pooled_recv_operation_mgr;
	std::vector<vdt_io_operation*> _all_recving_operation; // ���е��첽operation����أ����ڽ���

//	vdt_io_operation*		_recv_operation_ptr; // �첽������Ӧ���첽��������ָ��: ����

	std::list<IGameCommand *> _command_queue; // �������
	bool _using_udp_protocol;
protected:
	std::string				_host; // ����������(�����ж��)
	std::string				_curr_host; // ��ǰ����������
	unsigned short			_port; // �������˿�
	unsigned int	_host_ip;  // ʹ��UDP��Ҫ�Լ�������������
    bool _connection_finished;   
	int _request_send_times;
	int _response_recv_times;

	int m_conn_id;
	bool	_is_session_conn;

	bool _is_tracer_enabled;
	bool _proxy_connected;
	bool _sending_http_connect;
public:
	enum svr_type
	{
		portal_server=0, // 0:portal_server, 1 session_server , 2 stat_server
		session_server,
		stat_server,
	};
	int get_server_type() { return _server_type; };
	void set_server_type(short server_type) { _server_type=server_type; };

protected:
	short _server_type;

private:
	DECL_LOGGER;
};

#endif // #ifndef __ABSTRACT_C2S_CMD_HANDLER_H_
