/**
 * @license
 * SPDX-License-Identifier: Apache-2.0
 */

import React, { useEffect, useState, useMemo } from 'react';
import { 
  Heart, 
  Activity, 
  Footprints, 
  AlertTriangle, 
  ShieldCheck, 
  LogOut, 
  LayoutDashboard, 
  History, 
  Users, 
  ChevronRight,
  Plus
} from 'lucide-react';
import { 
  LineChart, 
  Line, 
  XAxis, 
  YAxis, 
  CartesianGrid, 
  Tooltip, 
  ResponsiveContainer,
  AreaChart,
  Area
} from 'recharts';
import { motion, AnimatePresence } from 'motion/react';
import { 
  auth, 
  db, 
  googleProvider, 
  signInWithPopup, 
  signInWithEmailAndPassword,
  createUserWithEmailAndPassword,
  signOut, 
  onAuthStateChanged, 
  collection, 
  doc, 
  onSnapshot, 
  query, 
  where, 
  orderBy, 
  limit,
  User,
  setDoc,
  serverTimestamp,
  handleFirestoreError,
  OperationType,
  testFirestoreConnection
} from './lib/firebase';
import { ErrorBoundary } from './components/ErrorBoundary';

// Types
interface HeartRateLog {
  id: string;
  heartRate: number;
  steps?: number;
  spo2?: number | null;
  createdAt: any; // Firebase Timestamp or ISO string
}

interface HeartRateBreakdown {
  id: string;
  heartRate: number;
  hour: number;
  date: any;
  createdAt: any;
}

interface UserProfile {
  uid: string;
  email: string;
  displayName: string;
  fullName?: string;
  age?: string;
  gender?: string;
  height?: string;
  weight?: string;
  role?: string;
  lastLogin?: any;
}

interface RiskEntry {
  id: string;
  uid: string;
  date: string;
  riskLevel: 'low' | 'moderate' | 'high' | 'critical';
  summary: string;
  advice: string;
}

interface AIInsight {
  id: string;
  heartRate: number;
  risk: string;
  summary: string;
  advice: string;
  date: any;
  createdAt: any;
}

export default function App() {
  const [user, setUser] = useState<User | null>(null);
  const [loading, setLoading] = useState(true);
  const [profile, setProfile] = useState<UserProfile | null>(null);
  const [heartLogs, setHeartLogs] = useState<HeartRateLog[]>([]);
  const [healthData, setHealthData] = useState<any[]>([]); // Fallback for trend chart
  const [riskHistory, setRiskHistory] = useState<RiskEntry[]>([]);
  const [aiInsights, setAiInsights] = useState<AIInsight[]>([]);
  const [activeTab, setActiveTab] = useState<'dashboard' | 'history' | 'profile'>('dashboard');
  const [chartView, setChartView] = useState<'daily' | 'weekly' | 'monthly'>('daily');
  const [isSyncing, setIsSyncing] = useState(false);
  const [showNoDataPopup, setShowNoDataPopup] = useState(false);
  const [breakdownLogs, setBreakdownLogs] = useState<HeartRateBreakdown[]>([]);

  // Current Day Stats (Resets at Midnight)
  const todayStats = useMemo(() => {
    const now = new Date();
    const startOfDay = new Date(now.getFullYear(), now.getMonth(), now.getDate());
    
    // heartLogs are sorted by createdAt desc, so we just find the first one from today
    const latestToday = heartLogs.find(log => {
      const logDate = log.createdAt?.toDate ? log.createdAt.toDate() : new Date(log.createdAt);
      return logDate >= startOfDay;
    });

    return {
      heartRate: latestToday ? latestToday.heartRate : null,
      steps: latestToday ? latestToday.steps : 0,
      hasDataToday: !!latestToday
    };
  }, [heartLogs]);

  // Daily Hourly Breakdown (Mirroring Flutter Service Logic or direct from Firestore)
  const dailyBreakdown = useMemo(() => {
    // If we have data from the heart_rate_breakdown collection, use that
    if (breakdownLogs.length > 0) {
      return Array.from({ length: 24 }, (_, hour) => {
        const found = breakdownLogs.find(b => b.hour === hour);
        return {
          hour: `${hour.toString().padStart(2, '0')}:00`,
          heartRate: found ? found.heartRate : null,
          displayRate: found ? found.heartRate : 0
        };
      });
    }

    // Fallback: Client-side logic for heart_rate_logs (if breakdown collection is empty)
    const buckets: Record<number, number[]> = {};
    const now = new Date();
    const startOfDay = new Date(now.getFullYear(), now.getMonth(), now.getDate());

    // Filter and bucket logs from today
    heartLogs.forEach(log => {
      const logDate = log.createdAt?.toDate ? log.createdAt.toDate() : new Date(log.createdAt);
      if (logDate >= startOfDay) {
        const hour = logDate.getHours();
        if (!buckets[hour]) buckets[hour] = [];
        buckets[hour].push(log.heartRate);
      }
    });

    // Generate 24-hour data points (0-23)
    return Array.from({ length: 24 }, (_, hour) => {
      const values = buckets[hour];
      const avg = values && values.length > 0 
        ? Math.round(values.reduce((a, b) => a + b) / values.length)
        : null;
      
      return {
        hour: `${hour.toString().padStart(2, '0')}:00`,
        heartRate: avg,
        displayRate: avg || 0
      };
    });
  }, [heartLogs, breakdownLogs]);

  // Weekly and Monthly Trends (Mirroring Flutter Logic)
  const periodicTrends = useMemo(() => {
    const now = new Date();
    const today = new Date(now.getFullYear(), now.getMonth(), now.getDate());
    const weekDayShort = ['S', 'M', 'T', 'W', 'T', 'F', 'S']; // JS getDay() is 0-indexed (Sun-Sat)

    const getDailyAverages = (days: number) => {
      const breakdown: Record<string, number[]> = {};
      const results = [];

      for (let i = 0; i < days; i++) {
        const d = new Date(today);
        d.setDate(d.getDate() - (days - 1 - i));
        const key = d.toDateString();
        breakdown[key] = [];
        
        // Labeling
        let label = '';
        if (days === 7) {
          label = weekDayShort[d.getDay()];
        } else {
          if (i === 0) label = '-30d';
          else if (i === 14) label = '-15d';
          else if (i === days - 1) label = 'Today';
        }

        results.push({ key, label, heartRate: null });
      }

      // Populate with real data
      heartLogs.forEach(log => {
        const logDate = log.createdAt?.toDate ? log.createdAt.toDate() : new Date(log.createdAt);
        const key = new Date(logDate.getFullYear(), logDate.getMonth(), logDate.getDate()).toDateString();
        if (breakdown[key] !== undefined) {
          breakdown[key].push(log.heartRate);
        }
      });

      return results.map(r => {
        const vals = breakdown[r.key];
        const avg = vals.length > 0 ? Math.round(vals.reduce((a, b) => a + b) / vals.length) : null;
        return { ...r, heartRate: avg };
      });
    };

    return {
      weekly: getDailyAverages(7),
      monthly: getDailyAverages(30)
    };
  }, [heartLogs]);

  // Unified Insight History
  const unifiedHistory = useMemo(() => {
    const historicalEntries = riskHistory.map(entry => ({
      id: entry.id,
      date: entry.date,
      sortDate: new Date(entry.date).getTime(),
      risk: entry.riskLevel,
      summary: entry.summary,
      advice: entry.advice,
      heartRate: null,
      source: 'Standard Analysis'
    }));

    const aiEntries = aiInsights.map(insight => {
      const insightDate = insight.date?.toDate ? insight.date.toDate() : new Date(insight.date);
      return {
        id: insight.id,
        date: insightDate.toLocaleDateString(),
        sortDate: insightDate.getTime(),
        risk: insight.risk,
        summary: insight.summary,
        advice: insight.advice,
        heartRate: insight.heartRate,
        source: 'Gemini AI Insight'
      };
    });

    return [...historicalEntries, ...aiEntries].sort((a, b) => b.sortDate - a.sortDate);
  }, [riskHistory, aiInsights]);

  useEffect(() => {
    testFirestoreConnection();
    const unsubscribe = onAuthStateChanged(auth, async (u) => {
      // Check if this is a fresh login transition
      if (u) {
        setIsSyncing(true);
        setTimeout(() => setIsSyncing(false), 2000);
      }
      setUser(u);
      
      // Always stop the initial full-screen spinner once auth state is determined
      setLoading(false);
      
      if (!u) {
        setProfile(null);
      }
    });
    return () => unsubscribe();
  }, []); // Empty dependency array is critical for the auth listener

  const refreshData = () => {
    setIsSyncing(true);
    setTimeout(() => setIsSyncing(false), 1500);
  };

  // Listen for Profile Changes
  useEffect(() => {
    if (!user) return;
    const unsubscribe = onSnapshot(doc(db, 'users', user.uid), (d) => {
      if (d.exists()) {
        setProfile(d.data() as UserProfile);
      }
      setLoading(false);
    });
    return () => unsubscribe();
  }, [user]);

  // Listen for Heart Rate Logs (Subcollection)
  useEffect(() => {
    if (!user) return;

    const q = query(
      collection(db, 'users', user.uid, 'heart_rate_logs'),
      orderBy('createdAt', 'desc'),
      limit(500)
    );

    const unsubscribe = onSnapshot(q, (snapshot) => {
      const logs = snapshot.docs.map(d => {
        const data = d.data();
        // Support multiple field names for heart rate, prioritizing heartRate
        const rate = data.heartRate || data.heart_rate_logs || data.bpm || data.value || 0;
        return { 
          id: d.id, 
          heartRate: rate, 
          steps: data.steps || 0,
          spo2: data.spo2,
          createdAt: data.createdAt || data.timestamp || null
        } as HeartRateLog;
      });
      setHeartLogs(logs);
      
      // Transform logs for the chart
      const chartData = [...logs].reverse().map(l => ({
        date: l.createdAt?.toDate ? l.createdAt.toDate().toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' }) : 'Pending',
        avgHeartRate: l.heartRate
      }));
      setHealthData(chartData);
    }, (error) => {
      handleFirestoreError(error, OperationType.GET, `users/${user.uid}/heart_rate_logs`);
    });

    return () => unsubscribe();
  }, [user]);

  // Listen for Heart Rate Breakdown (Subcollection)
  useEffect(() => {
    if (!user) return;

    const now = new Date();
    const startOfDay = new Date(now.getFullYear(), now.getMonth(), now.getDate());

    const q = query(
      collection(db, 'users', user.uid, 'heart_rate_breakdown'),
      where('date', '>=', startOfDay),
      orderBy('date', 'desc'),
      orderBy('hour', 'asc'),
      limit(24)
    );

    const unsubscribe = onSnapshot(q, (snapshot) => {
      const logs = snapshot.docs.map(d => ({ 
        id: d.id, 
        ...d.data() 
      } as HeartRateBreakdown));
      setBreakdownLogs(logs);
    }, (error) => {
      console.warn('Breakdown fetch error (check indices):', error);
      // Fallback is handled in useMemo
    });

    return () => unsubscribe();
  }, [user]);

  // Listen for AI Insights (Subcollection)
  useEffect(() => {
    if (!user) return;

    const q = query(
      collection(db, 'users', user.uid, 'ai_insights'),
      orderBy('createdAt', 'desc'),
      limit(5)
    );

    const unsubscribe = onSnapshot(q, (snapshot) => {
      const insights = snapshot.docs.map(d => ({ 
        id: d.id, 
        ...d.data() 
      } as AIInsight));
      setAiInsights(insights);
    }, (error) => {
      console.warn('AI Insights fetch error:', error);
    });

    return () => unsubscribe();
  }, [user]);

  // Check for Missing Data after Login/Sync
  useEffect(() => {
    if (!user || isSyncing || loading) return;

    // We check after a short delay to ensure initial snapshots have settled
    const timer = setTimeout(() => {
      if (heartLogs.length === 0 && breakdownLogs.length === 0) {
        setShowNoDataPopup(true);
      }
    }, 1500);

    return () => clearTimeout(timer);
  }, [user, isSyncing, loading, heartLogs, breakdownLogs]);

  // Listen for Risk History
  useEffect(() => {
    if (!user) return;

    const q = query(
      collection(db, 'risk_history'),
      where('uid', '==', user.uid),
      orderBy('date', 'desc'),
      limit(10)
    );

    const unsubscribe = onSnapshot(q, (snapshot) => {
      const data = snapshot.docs.map(d => ({ id: d.id, ...d.data() } as RiskEntry));
      setRiskHistory(data);
    }, (error) => {
      handleFirestoreError(error, OperationType.GET, 'risk_history');
    });

    return () => unsubscribe();
  }, [user]);

  const handleLogin = async () => {
    try {
      await signInWithPopup(auth, googleProvider);
    } catch (error) {
      console.error('Login failed', error);
    }
  };

  const handleLogout = () => signOut(auth);

  const simulateHeartRate = async () => {
    if (!user) return;
    try {
      const logRef = doc(collection(db, 'users', user.uid, 'heart_rate_logs'));
      await setDoc(logRef, {
        heartRate: Math.floor(Math.random() * (90 - 65 + 1)) + 65,
        steps: Math.floor(Math.random() * 10000),
        spo2: Math.floor(Math.random() * (100 - 95 + 1)) + 95,
        createdAt: serverTimestamp()
      });
    } catch (e) {
      console.error(e);
    }
  };

  if (loading) {
    return (
      <div className="min-h-screen flex items-center justify-center bg-minimal-bg">
        <div className="w-8 h-8 border-2 border-minimal-ink border-t-transparent rounded-full animate-spin" />
      </div>
    );
  }

  return (
    <ErrorBoundary>
      {!user ? (
        <LoginPage onLogin={handleLogin} />
      ) : (
        <div className="min-h-screen flex bg-minimal-bg">
          {/* Sidebar */}
          <aside className="w-64 bg-minimal-white border-r border-minimal-border flex flex-col p-8 hidden md:flex">
            <div className="mb-12">
              <span className="font-bold text-xl tracking-tight text-minimal-blue">VitaLife Assistant</span>
            </div>

            <nav className="flex-1 space-y-1">
              <NavButton 
                active={activeTab === 'dashboard'} 
                onClick={() => setActiveTab('dashboard')} 
                icon={<LayoutDashboard size={18} />}
                label="Overview"
              />
              <NavButton 
                active={activeTab === 'profile'} 
                onClick={() => setActiveTab('profile')} 
                icon={<Users size={18} />}
                label="Biometrics"
              />
              <NavButton 
                active={activeTab === 'history'} 
                onClick={() => setActiveTab('history')} 
                icon={<History size={18} />}
                label="Risk History"
              />
            </nav>

            <button 
              onClick={handleLogout}
              className="flex items-center gap-3 text-minimal-muted hover:text-minimal-ink transition-colors pt-6 border-t border-minimal-border"
            >
              <LogOut size={18} />
              <span>Sign Out</span>
            </button>
          </aside>

          {/* Main Content */}
          <main className="flex-1 overflow-y-auto p-4 md:p-12 max-w-6xl mx-auto relative">
            <AnimatePresence>
              {isSyncing && (
                <motion.div 
                  initial={{ opacity: 0 }}
                  animate={{ opacity: 1 }}
                  exit={{ opacity: 0 }}
                  className="absolute inset-0 z-50 bg-minimal-bg/60 backdrop-blur-sm flex items-center justify-center pointer-events-none"
                >
                  <div className="glass-panel p-8 rounded-3xl flex flex-col items-center gap-4 shadow-2xl relative">
                    <div className="w-10 h-10 border-4 border-minimal-blue border-t-transparent rounded-full animate-spin" />
                    <p className="text-sm font-semibold text-minimal-ink tracking-tight">Syncing Health Metrics...</p>
                  </div>
                </motion.div>
              )}
            </AnimatePresence>

            {/* No Data Modal */}
            <AnimatePresence>
              {showNoDataPopup && (
                <div className="fixed inset-0 z-[60] flex items-center justify-center p-6 bg-minimal-ink/40 backdrop-blur-md">
                  <motion.div 
                    initial={{ opacity: 0, scale: 0.9, y: 20 }}
                    animate={{ opacity: 1, scale: 1, y: 0 }}
                    exit={{ opacity: 0, scale: 0.9, y: 20 }}
                    className="glass-panel p-10 rounded-[40px] max-w-md w-full text-center shadow-3xl"
                  >
                    <div className="w-20 h-20 bg-amber-50 rounded-3xl flex items-center justify-center mx-auto mb-8 border border-amber-100">
                      <AlertTriangle className="text-amber-500" size={40} />
                    </div>
                    <h3 className="text-2xl font-bold mb-4 tracking-tight text-minimal-ink">No Health Data Detected</h3>
                    <p className="text-minimal-muted mb-8 text-sm leading-relaxed">
                      We couldn't find any recent vitals in your cloud vault. To start tracking:
                      <br/><br/>
                      1. Wear your **Smart Watch** or device.<br/>
                      2. Ensure **Google Fit** sync is enabled.<br/>
                      3. Check your mobile app connection.
                    </p>
                    <div className="space-y-3">
                      <button 
                        onClick={() => setShowNoDataPopup(false)}
                        className="w-full py-4 bg-minimal-ink text-white rounded-2xl font-semibold text-sm hover:opacity-90 transition-all active:scale-[0.98]"
                      >
                        Got it, I'll Check
                      </button>
                      <button 
                         onClick={() => window.open('https://fit.google.com', '_blank')}
                         className="w-full py-4 bg-minimal-white border border-minimal-border text-minimal-muted rounded-2xl font-semibold text-sm hover:bg-minimal-bg transition-all flex items-center justify-center gap-2"
                      >
                        Connect Google Fit
                      </button>
                    </div>
                  </motion.div>
                </div>
              )}
            </AnimatePresence>

            <header className="flex justify-between items-end mb-10">
              <div>
                <h1 className="text-3xl font-semibold tracking-tight text-minimal-ink">Health Dashboard</h1>
                <div className="flex items-center gap-2 text-minimal-muted mt-1 text-sm">
                  <div className={`w-2 h-2 rounded-full ${isSyncing ? 'bg-minimal-blue animate-pulse' : 'bg-minimal-green'}`} />
                  {isSyncing ? 'Syncing Cloud Vault...' : 'Direct Cloud Sync Active'}
                </div>
              </div>
              <div className="flex items-center gap-4">
                <button 
                  onClick={refreshData}
                  className="hidden sm:flex items-center gap-2 px-4 py-2 border border-minimal-border rounded-xl text-xs font-medium text-minimal-muted hover:bg-minimal-white transition-all mr-2"
                >
                  Refresh
                </button>
                <button 
                  onClick={simulateHeartRate}
                  className="hidden sm:flex items-center gap-2 px-4 py-2 border border-minimal-border rounded-xl text-xs font-medium text-minimal-muted hover:bg-minimal-white transition-all mr-2"
                >
                  <Plus size={14} /> Simulate Log
                </button>
                <div className="text-right hidden sm:block">
                  <p className="text-sm font-semibold text-minimal-ink">{user.displayName}</p>
                  <p className="text-xs text-minimal-muted">Standard Account</p>
                </div>
                <img 
                  src={user.photoURL || `https://picsum.photos/seed/${user.uid}/100/100`} 
                  alt="Profile" 
                  className="w-10 h-10 rounded-full border border-minimal-border"
                />
              </div>
            </header>

            <AnimatePresence mode="wait">
              {activeTab === 'dashboard' && (
                <motion.div
                  key="dashboard"
                  initial={{ opacity: 0, y: 10 }}
                  animate={{ opacity: 1, y: 0 }}
                  exit={{ opacity: 0, y: -10 }}
                  className="space-y-8"
                >
                  <div className="grid grid-cols-1 md:grid-cols-5 gap-4">
                    <StatCard 
                      label="Current HR" 
                      value={todayStats.hasDataToday ? todayStats.heartRate?.toString() || '--' : '--'} 
                      unit="BPM"
                    />
                    <StatCard 
                      label="Steps" 
                      value={todayStats.hasDataToday ? todayStats.steps.toLocaleString() : '0'} 
                      unit="steps"
                    />
                    <StatCard 
                      label="Weight" 
                      value={profile?.weight || '--'} 
                      unit="kg"
                    />
                    <StatCard 
                      label="Height" 
                      value={profile?.height || '--'} 
                      unit="cm"
                    />
                    <StatCard 
                      label="Age" 
                      value={profile?.age || '--'} 
                      unit="yrs"
                    />
                  </div>

                  {/* AI Risk Highlight */}
                  {(() => {
                    const latestRisk = aiInsights[0]?.risk || riskHistory[0]?.riskLevel || 'Low';
                    let bgClass = 'ai-gradient';
                    let healthIndex = '94';
                    
                    if (latestRisk === 'High' || latestRisk === 'high' || latestRisk === 'High Risk') {
                      bgClass = 'ai-gradient-high';
                      healthIndex = '82';
                    } else if (latestRisk === 'critical' || latestRisk === 'Critical' || latestRisk === 'Danger') {
                      bgClass = 'ai-gradient-high';
                      healthIndex = '94';
                    } else if (latestRisk === 'moderate' || latestRisk === 'medium' || latestRisk === 'Medium') {
                      bgClass = 'ai-gradient-medium';
                      healthIndex = '40';
                    } else if (latestRisk === 'need care' || latestRisk === 'Need Care') {
                      bgClass = 'ai-gradient-care';
                      healthIndex = '60';
                    } else {
                      bgClass = 'ai-gradient-low';
                      healthIndex = '20';
                    }

                    return (
                      <div className={`${bgClass} p-8 rounded-3xl flex justify-between items-center shadow-lg transition-colors duration-500`}>
                        <div className="space-y-2">
                          <h2 className="text-xl font-semibold">Gemini AI Analysis</h2>
                          <p className="text-white/90 text-sm max-w-xl leading-relaxed">
                            {aiInsights[0]?.summary || riskHistory[0]?.summary || 'Based on your vitals over the last 24 hours, your heart rate recovery is performing optimally. We detected no significant anomalies in your physical activity patterns.'}
                          </p>
                          {(aiInsights[0]?.advice || riskHistory[0]?.advice) && (
                            <p className="text-xs font-medium bg-white/10 p-2 rounded-lg border border-white/20 mt-2">
                              💡 Advice: {aiInsights[0]?.advice || riskHistory[0]?.advice}
                            </p>
                          )}
                        </div>
                        <div className="text-right">
                          <div className="text-[10px] uppercase tracking-widest opacity-80 font-bold mb-1">Health Index</div>
                          <div className="text-5xl font-bold leading-tight">
                            {healthIndex}
                          </div>
                          <div className="text-[10px] uppercase tracking-widest opacity-80 font-bold">
                            {latestRisk} Risk
                          </div>
                        </div>
                      </div>
                    );
                  })()}

                   {/* Chart Section */}
                   <div className="glass-panel p-8 rounded-3xl h-[450px] flex flex-col">
                     <div className="flex flex-col sm:flex-row justify-between items-start sm:items-center mb-8 gap-4">
                       <div>
                         <h3 className="font-semibold text-lg text-minimal-ink">Heart Rate Trends</h3>
                         <p className="text-xs text-minimal-muted">
                           {chartView === 'daily' ? '24-Hour Average Breakdown' : 
                            chartView === 'weekly' ? 'Last 7 Days Trend' : 'Last 30 Days Trend'}
                         </p>
                       </div>
                       
                       <div className="flex bg-minimal-bg p-1 rounded-xl border border-minimal-border">
                         {(['daily', 'weekly', 'monthly'] as const).map((view) => (
                           <button
                             key={view}
                             onClick={() => setChartView(view)}
                             className={`px-4 py-1.5 rounded-lg text-[10px] font-bold uppercase tracking-widest transition-all ${
                               chartView === view 
                                 ? 'bg-white text-minimal-ink shadow-sm ring-1 ring-black/5' 
                                 : 'text-minimal-muted hover:text-minimal-ink'
                             }`}
                           >
                             {view}
                           </button>
                         ))}
                       </div>
                     </div>

                     <ResponsiveContainer width="100%" height="100%">
                       <AreaChart 
                         data={
                           chartView === 'daily' ? dailyBreakdown : 
                           chartView === 'weekly' ? periodicTrends.weekly : 
                           periodicTrends.monthly
                         }
                       >
                         <defs>
                           <linearGradient id="colorHr" x1="0" y1="0" x2="0" y2="1">
                             <stop offset="5%" stopColor="#7EA0EA" stopOpacity={0.1}/>
                             <stop offset="95%" stopColor="#7EA0EA" stopOpacity={0}/>
                           </linearGradient>
                         </defs>
                         <CartesianGrid strokeDasharray="3 3" stroke="#E5E5E7" vertical={false} />
                         <XAxis 
                           dataKey={chartView === 'daily' ? "hour" : "label"} 
                           stroke="#86868B" 
                           fontSize={11} 
                           tickLine={false} 
                           axisLine={false} 
                           interval={chartView === 'monthly' ? 0 : (chartView === 'daily' ? 3 : 0)}
                           padding={{ left: 20, right: 20 }}
                         />
                         <YAxis 
                           stroke="#86868B" 
                           fontSize={11} 
                           tickLine={false} 
                           axisLine={false} 
                           domain={[40, 'auto']}
                         />
                         <Tooltip 
                           contentStyle={{ background: '#FFFFFF', border: '1px solid #E5E5E7', borderRadius: '12px', boxShadow: '0 4px 12px rgba(0,0,0,0.05)' }}
                           itemStyle={{ color: '#7EA0EA' }}
                           formatter={(value: any) => [value ? `${value} BPM` : '--', 'Avg Heart Rate']}
                         />
                         <Area 
                           type="monotone" 
                           dataKey="heartRate" 
                           stroke="#7EA0EA" 
                           strokeWidth={2.5}
                           fillOpacity={1} 
                           fill="url(#colorHr)"
                           connectNulls={true}
                           dot={chartView !== 'monthly' ? { r: 4, fill: '#7EA0EA', strokeWidth: 2, stroke: '#fff' } : false}
                           activeDot={{ r: 6, strokeWidth: 0 }}
                         />
                       </AreaChart>
                     </ResponsiveContainer>
                   </div>
                </motion.div>
              )}

              {activeTab === 'history' && (
                <motion.div
                  key="history"
                  initial={{ opacity: 0, x: 20 }}
                  animate={{ opacity: 1, x: 0 }}
                  exit={{ opacity: 0, x: -20 }}
                  className="space-y-6"
                >
                  <h3 className="text-xl font-semibold mb-6">Health Insight History</h3>
                  <div className="space-y-4">
                    {unifiedHistory.map((item) => (
                      <div key={item.id} className="glass-panel p-6 rounded-3xl flex flex-col md:flex-row gap-6 items-start">
                        <div className="md:w-40 shrink-0">
                          <p className="text-xs font-bold text-minimal-muted uppercase tracking-widest mb-1">{item.source}</p>
                          <p className="text-sm font-semibold text-minimal-ink">{item.date}</p>
                          <span className={`text-[10px] font-bold uppercase tracking-widest inline-block px-2 py-0.5 rounded mt-2 ${
                            item.risk === 'High' || item.risk === 'critical' || item.risk === 'Critical' || item.risk === 'High Risk' ? 'bg-red-50 text-red-600' :
                            item.risk === 'moderate' || item.risk === 'medium' || item.risk === 'Medium' || item.risk === 'need care' ? 'bg-amber-50 text-amber-600' : 
                            'bg-emerald-50 text-emerald-600'
                          }`}>
                            {item.risk} Risk
                          </span>
                        </div>
                        <div className="flex-1">
                          <div className="flex justify-between items-start mb-2">
                            <h4 className="font-semibold text-minimal-ink">{item.summary}</h4>
                            {item.heartRate && (
                              <span className="text-xs font-bold bg-minimal-bg px-2 py-1 rounded-lg border border-minimal-border">
                                {item.heartRate} BPM
                              </span>
                            )}
                          </div>
                          <p className="text-sm text-minimal-muted leading-relaxed">{item.advice}</p>
                        </div>
                      </div>
                    ))}
                    {unifiedHistory.length === 0 && (
                      <div className="py-20 text-center text-zinc-500 italic flex flex-col items-center gap-4">
                        <div className="w-16 h-16 bg-minimal-bg rounded-full flex items-center justify-center">
                          <AlertTriangle size={24} className="text-minimal-muted" />
                        </div>
                        No historical health insights found.
                      </div>
                    )}
                  </div>
                </motion.div>
              )}

              {activeTab === 'profile' && (
                <motion.div
                  key="profile"
                  initial={{ opacity: 0, x: 20 }}
                  animate={{ opacity: 1, x: 0 }}
                  exit={{ opacity: 0, x: -20 }}
                  className="space-y-6"
                >
                  <h3 className="text-xl font-semibold mb-6">User Biometrics</h3>
                  <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                    <div className="glass-panel p-8 rounded-3xl space-y-4">
                      <div className="flex justify-between border-b border-minimal-border pb-4">
                        <span className="text-minimal-muted">Full Name</span>
                        <span className="font-semibold">{profile?.fullName || '--'}</span>
                      </div>
                      <div className="flex justify-between border-b border-minimal-border pb-4">
                        <span className="text-minimal-muted">Gender</span>
                        <span className="font-semibold capitalize">{profile?.gender || '--'}</span>
                      </div>
                      <div className="flex justify-between border-b border-minimal-border pb-4">
                        <span className="text-minimal-muted">Age</span>
                        <span className="font-semibold">{profile?.age || '--'} years</span>
                      </div>
                      <div className="flex justify-between">
                        <span className="text-minimal-muted">Role</span>
                        <span className="font-semibold uppercase text-xs tracking-widest">{profile?.role || 'user'}</span>
                      </div>
                    </div>
                    
                    <div className="glass-panel p-8 rounded-3xl space-y-4">
                      <div className="flex justify-between border-b border-minimal-border pb-4">
                        <span className="text-minimal-muted">Height</span>
                        <span className="font-semibold">{profile?.height || '--'} cm</span>
                      </div>
                      <div className="flex justify-between border-b border-minimal-border pb-4">
                        <span className="text-minimal-muted">Weight</span>
                        <span className="font-semibold">{profile?.weight || '--'} kg</span>
                      </div>
                      <div className="flex justify-between border-b border-minimal-border pb-4">
                        <span className="text-minimal-muted">BMI</span>
                        <span className="font-semibold">
                          {profile?.height && profile?.weight 
                            ? (Number(profile.weight) / ((Number(profile.height)/100)**2)).toFixed(1) 
                            : '--'}
                        </span>
                      </div>
                    </div>
                  </div>
                </motion.div>
              )}
            </AnimatePresence>
          </main>
        </div>
      )}
    </ErrorBoundary>
  );
}

function LoginPage({ onLogin }: { onLogin: () => void }) {
  const [isRegistering, setIsRegistering] = useState(false);
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState<string | null>(null);
  const [loading, setLoading] = useState(false);

  const handleEmailAuth = async (e: React.FormEvent) => {
    e.preventDefault();
    setError(null);
    setLoading(true);

    try {
      if (isRegistering) {
        await createUserWithEmailAndPassword(auth, email, password);
      } else {
        await signInWithEmailAndPassword(auth, email, password);
      }
    } catch (err: any) {
      setError(err.message || 'An error occurred during authentication');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="min-h-screen flex items-center justify-center bg-minimal-bg p-6">
      <motion.div 
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        className="glass-panel p-8 md:p-12 rounded-[40px] max-w-md w-full text-center relative z-10"
      >
        <div className="w-16 h-16 bg-vital-400 text-white rounded-2xl flex items-center justify-center mx-auto mb-8 shadow-xl shadow-vital-400/20">
          <Heart size={32} fill="currentColor" />
        </div>
        <h1 className="text-3xl font-bold mb-2 tracking-tight text-minimal-ink">VitaLife Assistant</h1>
        <p className="text-minimal-muted mb-8 text-sm leading-relaxed">
          {isRegistering ? 'Create your health account' : 'Welcome back to your health intelligence'}
        </p>

        <form onSubmit={handleEmailAuth} className="space-y-4 mb-6">
          <div className="text-left space-y-1">
            <label className="text-[10px] uppercase font-bold text-minimal-muted tracking-widest px-2">Email Address</label>
            <input 
              type="email" 
              required
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              className="w-full px-4 py-3 bg-minimal-white border border-minimal-border rounded-xl focus:ring-2 focus:ring-minimal-blue/20 outline-none transition-all text-sm"
              placeholder="name@example.com"
            />
          </div>
          <div className="text-left space-y-1">
            <label className="text-[10px] uppercase font-bold text-minimal-muted tracking-widest px-2">Password</label>
            <input 
              type="password" 
              required
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              className="w-full px-4 py-3 bg-minimal-white border border-minimal-border rounded-xl focus:ring-2 focus:ring-minimal-blue/20 outline-none transition-all text-sm"
              placeholder="••••••••"
            />
          </div>
          
          {error && <p className="text-xs text-red-500 mt-2 bg-red-50 p-2 rounded-lg border border-red-100">{error}</p>}

          <button 
            type="submit"
            disabled={loading}
            className="w-full py-3 bg-minimal-ink text-white rounded-xl font-semibold text-sm hover:opacity-90 transition-all active:scale-[0.98] disabled:opacity-50"
          >
            {loading ? 'Processing...' : (isRegistering ? 'Create Account' : 'Sign In')}
          </button>
        </form>

        <div className="relative mb-6">
          <div className="absolute inset-0 flex items-center"><div className="w-full border-t border-minimal-border"></div></div>
          <div className="relative flex justify-center text-[10px] uppercase tracking-widest"><span className="bg-minimal-white px-4 text-minimal-muted font-bold">Or continue with</span></div>
        </div>
        
        <button 
          onClick={onLogin}
          type="button"
          className="w-full py-3 bg-minimal-white border border-minimal-border text-minimal-ink rounded-xl font-semibold text-sm hover:bg-minimal-bg transition-all flex items-center justify-center gap-3 active:scale-[0.98]"
        >
          <img src="https://www.google.com/favicon.ico" alt="Google" className="w-4 h-4" />
          Google Account
        </button>

        <p className="mt-8 text-xs text-minimal-muted">
          {isRegistering ? 'Already have an account?' : "Don't have an account?"}{' '}
          <button 
            onClick={() => setIsRegistering(!isRegistering)}
            className="text-minimal-blue font-bold hover:underline"
          >
            {isRegistering ? 'Sign In' : 'Create one'}
          </button>
        </p>
      </motion.div>
    </div>
  );
}

function StatCard({ label, value, unit, trend, trendColor }: { label: string, value: string, unit: string, trend?: string, trendColor?: string }) {
  return (
    <div className="glass-panel p-8 rounded-[20px] transition-all hover:translate-y-[-2px]">
      <div className="flex flex-col gap-1">
        <p className="text-[10px] uppercase font-bold text-minimal-muted tracking-widest mb-2">{label}</p>
        <div className="flex items-baseline gap-2">
          <h4 className="text-4xl font-light tracking-tight text-minimal-ink">{value}</h4>
          <span className="text-base font-medium text-minimal-muted">{unit}</span>
        </div>
        {trend && <p className={`text-xs mt-3 font-medium text-minimal-muted text-${trendColor}`}>{trend}</p>}
      </div>
    </div>
  );
}

function NavButton({ active, onClick, icon, label }: { active: boolean, onClick: () => void, icon: React.ReactNode, label: string }) {
  return (
    <button 
      onClick={onClick}
      className={`w-full flex items-center gap-3 px-0 py-3 rounded-xl text-sm font-medium transition-all ${
        active 
          ? 'text-minimal-ink' 
          : 'text-minimal-muted hover:text-minimal-ink'
      }`}
    >
      <span className={active ? 'text-minimal-blue' : ''}>{icon}</span>
      <span>{label}</span>
    </button>
  );
}
