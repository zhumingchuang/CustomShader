// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "CustomShader_1"
{
    Properties
    {
        _Float("Float",Float)=0.0
        _Range("Range",Range(0.0,1.0))=0.0
        _Vector("Vector",Vector)=(1,1,1,1)
        _Color("Color",Color)=(0.5,0.5,0.5,0.5)
        _MainTex("MainTex",2D)="black"{}
        
        [Enum(UnityEngine.Rendering.CullMode)]_CullMode("CullMode",float)=2
    }
    SubShader
    {
        Pass
        {
            //剔除模式
            Cull [_CullMode]
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            //从模型中获取的数据结构
            struct appdata
            {
                //模型空间顶点信息
                float4 vertex :POSITION;
                //UV信息
                float2 uv: TEXCOORD0;
            };

            //输出结构
            struct v2f
            {
                float4 pos :SV_POSITION;
                float2 uv: TEXCOORD0;
            };

            float4 _Color;
            sampler2D _MainTex;
            float4 _MainTex_ST;

            //顶点Shader
            v2f vert(appdata v)
            {
                v2f o;
                // float4 pos_world = mul(unity_ObjectToWorld, v.vertex); //模型空间转世界空间
                // float4 pos_view = mul(UNITY_MATRIX_V, pos_world); //世界空间转相机空间
                // float4 pos_clip = mul(UNITY_MATRIX_P, pos_view); //转到裁剪空间
                //o.pos = pos_clip;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv * _MainTex_ST.xy + _MainTex_ST.zw;
                return o;
            }

            //片源Shader
            float4 frag(v2f i):SV_Target
            {
                //采样贴图
                float4 col = tex2D(_MainTex, i.uv);
                return col;
            }
            ENDCG
        }
    }
}