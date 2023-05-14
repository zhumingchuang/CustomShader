/*
边缘光
*/
Shader "CustomShader/Rim"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color("Color",COlor)=(0,0,0,0)
        _Emiss("Emiss",float)=1
        _RimPower("RimPower",float)=1
        [Enum(UnityEngine.Rendering.CullMode)]_CullMode("CullMode",float)=2
    }
    SubShader
    {
        Tags
        {
            "RenderType"="Opaque"
        }
        LOD 100

        Pass
        {
            ZWrite off
            //使用柔和叠加模式
            Blend SrcAlpha One
            //剔除模式
            Cull [_CullMode]
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
                float3 normal_world : TEXCOORD1;
                float3 view_world : TEXCOORD2;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            half3 _Color;
            float _Emiss;
            float _RimPower;

            v2f vert(appdata v)
            {
                v2f o;
                //模型空间转到裁剪空间
                o.vertex = UnityObjectToClipPos(v.vertex);
                //计算世界空间法线
                o.normal_world = normalize(mul(float4(v.normal, 0.0), unity_WorldToObject).xyz);
                //计算世界空间顶点坐标
                float3 pos_world = mul(unity_ObjectToWorld, v.vertex).xyz;
                //计算视线方向 顶点指向相机的方向   _WorldSpaceCameraPos世界空间相机位置
                o.view_world = normalize(_WorldSpaceCameraPos.xyz - pos_world);

                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o, o.vertex);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                //光栅化过程或导致向量发生变化  再次标准化
                float3 normal_world = normalize(i.normal_world);
                float3 view_world = normalize(i.view_world);
                float NdotV = saturate(dot(normal_world, view_world));
                float3 col = _Color.xyz * _Emiss;
                float fresnel = pow(1.0 - NdotV, _RimPower);
                float alpha = saturate(fresnel * _Emiss);
                return float4(col, alpha);
            }
            ENDCG
        }
    }
}