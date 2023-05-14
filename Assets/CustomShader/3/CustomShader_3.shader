// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "CustomShader_3"
{
    Properties
    {
        _MainColor("MainColor",Color)=(0.5,0.5,0.5,0.5)
        _MainTex("MainTex",2D)="black"{}
        _Emiss("Emiss",float)=1.0

        [Enum(UnityEngine.Rendering.CullMode)]_CullMode("CullMode",float)=2
    }
    SubShader
    {
        Tags
        {
            //半透明需要修改半透明的渲染队列
            "Queue"="Transparent"
        }
        Pass
        {
            ZWrite off
            //Blend SrcAlpha OneMinusSrcAlpha //半透明效果
            //柔和叠加效果
            Blend SrcAlpha One
            
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

            float4 _MainColor;
            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _Emiss;

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
                half3 col = _MainColor.xyz * _Emiss;
                //saturate限制数值为0-1
                half alpha = saturate(tex2D(_MainTex, i.uv).r * _MainColor.a * _Emiss);
                return float4(col, alpha);
            }
            ENDCG
        }
    }
}