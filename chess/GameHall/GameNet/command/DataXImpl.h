#pragma once

#include "common/GameNetInf.h"
#include "common/FixedBuffer.h"

#include <map>
#include <vector>
#include <string>

using std::map;
using std::vector;
using std::string;

typedef map<short, string> DataIDToKeyMap;

#define MAKE_DATAX_INDEX(xType, pos)	((xType << 16) + pos)
#define GET_TYPE_FROM_DX_INDEX(nIndex)	(nIndex >> 16)
#define GET_POS_FROM_DX_INDEX(nIndex)	(nIndex & 0xFFFF)

class DataXImpl : public IDataXNet
{
	enum { DX_MAGIC_NUM = 0x385A };

	enum DataX_Types_Enum
	{
		DX_TYPE_MIN_VALUE = 1,
		DX_TYPE_SHORT = 1,
		DX_TYPE_INT	 = 2,
		DX_TYPE_INT64 = 3,
		DX_TYPE_BYTES = 4,
		DX_TYPE_WSTRING = 5,
		DX_TYPE_DATAX = 6,
		DX_TYPE_INTARRAY = 7,
		DX_TYPE_DATAXARRAY	= 8,
		DX_TYPE_UTF8STRING = 9,
		DX_TYPE_MAX_VALUE = 9
	};

	static DataIDToKeyMap m_sMapDataIDToKey;

public:
	DataXImpl(void);
	~DataXImpl(void);

	static void InitDataIDMap();

	static DataXImpl* DecodeFrom(byte* pbBuffer, int& nBufferLen);

	// ���ظ��������Ϊ����������������(��λ���ֽ���)
	int EncodedLength();

	/***********************************************************************************
	* ���������Ϊbuffer��ָ���ڴ��ϵĶ�������
	* buffer_size: [IN/OUT] ����ǰΪ�������ĳ�ʼ��С�����ú�����Ϊ�������������ĳ���
	/**********************************************************************************/
	void Encode(byte* pbBuffer, int &nBufferSize);

	// ���Լ���������ȫ����һ��
	IDataXNet* Clone();
	// �����е��������
	void Clear();
	// ����Ԫ������
	int GetSize();

	// ������ݲ����ӿ�
	// --------------------
	// ���Short��������
	bool PutShort(short nKeyID, short nData);
	// ���Int��������
	bool PutInt(short nKeyID, int nData);
	// ���64λ��������
	bool PutInt64(short nKeyID, __int64 nData);
	// ����ֽ����������
	bool PutBytes(short nKeyID, const byte* pbData, int nDataLen);
	// ��ӿ��ֽ��ַ���
	bool PutWString(short nKeyID, LPCWSTR pwszData, int nStringLen);
	// Ƕ��IDataXNet����
	bool PutDataX(short nKeyID, IDataXNet* pDataCmd);
	// ���Int���������
	bool PutIntArray(short nKeyID, int* pnData, int nElements);
	// ���IDataXNet����
	bool PutDataXArray(short nKeyID, IDataXNet** ppDataCmd, int nElements);
	// ���UTF-8������ַ���
	bool PutUTF8String(short nKeyID, const byte* pbData, int nDataLen);

	// ��ȡ���ݲ����ӿ�
	// ------------------------
	// ��ȡShort��������
	bool GetShort(short nKeyID, short& nData);
	// ��ȡInt��������
	bool GetInt(short nKeyID, int& nData);
	// ��ȡ64λ��������
	bool GetInt64(short nKeyID, __int64& nData) ;
	// ��ȡ�ֽ�����(���pbDataBufΪNULL, �����nBufferLen���ø��ֽ��������ݵ�ʵ�ʳ���)
	bool GetBytes(short nKeyID, byte* pbDataBuf, int& nBufferLen);
	// ��ȡ���ֽ��ַ���(���pwszDataBufΪNULL, �����nStringLen���ø��ַ�����ʵ�ʳ���)
	bool GetWString(short nKeyID, LPWSTR pwszDataBuf, int& nStringLen) ;
	// ��ȡǶ���������IDataXNet
	bool GetDataX(short nKeyID, IDataXNet** ppDataCmd);
	// ��ȡ���������Ԫ������
	bool GetIntArraySize(short nKeyID, int& nSize);
	// ��ȡ���������ĳ��Ԫ�أ�����������ţ�
	bool GetIntArrayElement(short nKeyID, int nIndex, int& nData);
	// ��ȡIDataXNet�����Ԫ������
	bool GetDataXArraySize(short nKeyID, int& nSize);
	// ��ȡIDataXNet�����ĳ��Ԫ�أ�����������ţ�
	bool GetDataXArrayElement(short nKeyID, int nIndex, IDataXNet** ppDataCmd);
	// ��ȡUTF8������ֽ�����(���pbDataBufΪNULL, �����nBufferLen���ø��ֽ��������ݵ�ʵ�ʳ���)
	bool GetUTF8String(short nKeyID, byte* pbDataBuf, int& nBufferLen);

	virtual string ToString();
	virtual jobject EncodeToBundle(JNIEnv *env);

private:
	void EncodeBytesItem(FixedBuffer& fixed_buffer, int nPos);
	void EncodeWStringItem(FixedBuffer& fixed_buffer, int nPos);
	void EncodeDataXItem(FixedBuffer& fixed_buffer, int nPos);
	void EncodeIntArrayItem(FixedBuffer& fixed_buffer, int nPos);
	void EncodeDataXArrayItem(FixedBuffer& fixed_buffer, int nPos);

	bool ModifyShort(short nKeyID, short nData);
	bool ModifyInt(short nKeyID, int nData);
	bool ModifyInt64(short nKeyID, __int64 nData);
	bool ModifyBytes(short nKeyID, const byte* pbData, int nDataLen);
	bool ModifyWString(short nKeyID, LPCWSTR pwszData, int nStringLen);
	bool ModifyUTF8String(short nKeyID, const byte* pbData, int nDataLen);

	unsigned CalcBytesItemLen(int nPos) { return sizeof(int) + m_vecBytesItems[nPos].length(); }
	unsigned CalcWStringItemLen(int nPos) { return sizeof(int) + m_vecWstrItems[nPos].length() * sizeof(WCHAR); }
	unsigned CalcDataXItemLen( int nPos) 
	{ 
		long nEncodedLen = m_vecDataXItems[nPos]->EncodedLength();
		//HRESULT hr = m_vecDataXItems[nPos]->EncodedLength(&nEncodedLen);
		return (unsigned)nEncodedLen;
	}
	unsigned CalcIntArrayItemLen(int nPos);
	unsigned CalcDataXArrayItemLen( int nPos);

	BOOL PutBytesItem(unsigned short nKeyID, FixedBuffer& fixed_buffer);
	BOOL PutUTF8BytesItem(unsigned short nKeyID, FixedBuffer& fixed_buffer);
	BOOL PutWStringItem(unsigned short nKeyID, FixedBuffer& fixed_buffer);
	BOOL PutDataXItem(unsigned short nKeyID, FixedBuffer& fixed_buffer);
	BOOL PutIntArrayItem(unsigned short nKeyID, FixedBuffer& fixed_buffer);
	BOOL PutDataXArrayItem(unsigned short nKeyID, FixedBuffer& fixed_buffer);

	bool PutDataXArray_Impl(short nKeyID, IDataXNet** ppDataCmd, int nElements, bool bGiveupDxOwnership = false);


private:
	map<short, int> m_mapIndexes;

	vector<int> m_vecIntItems;
	vector<__int64> m_vecInt64Items;
	vector<string> m_vecBytesItems;
	vector<std::wstring> m_vecWstrItems;
	vector<IDataXNet*> m_vecDataXItems;
	vector< vector<int> > m_vecIntArrayItems;
	vector< vector<IDataXNet*> > m_vecDataXArrayItems;

private:
	DECL_LOGGER;
};
